using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using resource;
using System.Net;
using System.IO;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace Portal
{
    public partial class _Default : Page
    {
        //variable to store bearer ID
        static string bearerId;
        //list of machines not required and to be removed
        List<string> machinesNotRequired = new List<string>();
        protected void Button1_Click(object sender, EventArgs e)
        {
            //edit the JSON file
            OperateOnJsonFile();
            //go to next page when the entire JSON is edited
            Response.Redirect("NewLog.aspx");
        }
        protected void OperateOnJsonFile()
        {
            //variable to store the json string of the arm template
            string json;
            //Download a file from github  
            using (var client = new WebClient())
            {
                json = client.DownloadString("https://raw.githubusercontent.com/prathammehta/DevOps/master/Misc/ARM%20DNS%20Multiple%20VM.json");
            }
            //Deserialise the JSON String 
            JObject deserialisedJSON = JObject.Parse(json);
            //Node to store the root node
            var json_parentNode = deserialisedJSON["properties"]["parameters"];
            var adminUsername = Request["adminUsername"];
            //iterate for each parameter user entered
            foreach (var para_name in GlobalClass.param)
            {
                EditJsonFromParameter(ref json, ref deserialisedJSON, ref json_parentNode, para_name);
            }
            int unixTimestamp = (int)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalSeconds;

            //this function edits the parameters set by our sysytem and not provided by the user
            EditImplicitParameters(json_parentNode, unixTimestamp);

            string resourceGroupPrefix = "devops";
            //set the resource group name
            var resourceGroupName = resourceGroupPrefix + (unixTimestamp.ToString());
            //set the session variables
            SetSessionVariables(resourceGroupName);
            var subscriptionID = Listbox3.Text;
            var location = Request["location"];
            //this will make the rest api call with the json fetched from Git-Hub
            MakeRequest.CreateResource(resourceGroupName, bearerId, subscriptionID, location, deserialisedJSON.ToString());

        }

        private void SetSessionVariables(string resourceGroupName)
        {
            Session["SubscriptionID"] = Listbox3.Text;// listbox3 ->subscription ID  
            Session["BearerID"] = bearerId;
            Session["Resource"] = resourceGroupName;
            Session["ResourcesRequested"] = JsonConvert.SerializeObject(GlobalClass.resources_provisioned);
        }

        private void EditImplicitParameters(JToken json_parentNode, int unixTimestamp)
        {
            string id = "";
            //set storage account name
            json_parentNode["newStorageAccountName"]["value"] = Request["adminUsername"] + (unixTimestamp.ToString());
            //opening the sql connection
            SqlConnection con = new SqlConnection("Data Source = k2wn7r8oxg.database.windows.net; Initial Catalog = DevOpsGD_db; User ID = devopsadmin; Password = Hello@123");
            con.Open();
            //this has key -> machine name & value -> radio button id
            Dictionary<string, RadioButtonList> radio_config_list = new Dictionary<string, RadioButtonList>()
            {
                { "dev",DevConfig },
                { "build",BuildConfig },
                { "test",TestConfig }
            };
            foreach (var selectedconfig in radio_config_list)
            {
                // check if the no of instances for a machine is not set to zero 
                if (!(machinesNotRequired.Contains(selectedconfig.Key)))
                {
                // read the configuration parameters from the database
                    SqlCommand cmd = new SqlCommand("Select * from configuration_params where config_id=" + selectedconfig.Value.SelectedValue, con);
                    SqlDataReader reader = cmd.ExecuteReader();
                    //iterating over all the parameters of the configuration
                    while (reader.Read())
                    {
                        json_parentNode[selectedconfig.Key + "imagePublisher"]["value"] = reader.GetValue(1).ToString();
                        json_parentNode[selectedconfig.Key + "imageOffer"]["value"] = reader.GetValue(2).ToString();
                        json_parentNode[selectedconfig.Key + "imageSKU"]["value"] = reader.GetValue(3).ToString();
                        json_parentNode[selectedconfig.Key + "modulesUrl"]["value"] = reader.GetValue(4).ToString();
                        json_parentNode[selectedconfig.Key + "configurationFunction"]["value"] = reader.GetValue(5).ToString();
                        id = reader.GetValue(6).ToString();
                    }
                    reader.Close();
                    //fetching the configuration description and storing for the tracing of provisioned resources
                    SqlCommand cmdForConfig = new SqlCommand("Select description from environment_configurations where config_id=" + id, con);
                    SqlDataReader readerForConfig = cmd.ExecuteReader();
                    while (readerForConfig.Read())
                    {
                        GlobalClass.resources_provisioned[selectedconfig.Key + " Virtual Machine Configuration"] = readerForConfig.GetValue(2).ToString();
                    }
                    readerForConfig.Close();

                }
            }
        }

        private void EditJsonFromParameter(ref string json, ref JObject deserialisedJSON, ref JToken json_parentNode, string para_name)
        {
            //check the no. of instances of virtual machines requisted
            if (Regex.IsMatch(para_name, @"[a-zA-Z0-9]*NumberOfInstances"))
            {
                var noOfInstances = int.Parse(Request[para_name]);
                //get the name of machine i.e dev ,build ,test
                var machineName = para_name.Replace("NumberOfInstances", "");
                //remove the resources with zero no of instances requisted
                if (Request[para_name] == "0")
                {
                    json = removeResourceFromJSON(json, out deserialisedJSON, out json_parentNode, machineName);
                }
                //update the no of instances of machines
                json_parentNode[para_name]["value"] = noOfInstances;
                //Store the no of instances provisioned
                GlobalClass.resources_provisioned[machineName + " Virtual Machines"] = noOfInstances.ToString();
            }
            else
            {
                json_parentNode[para_name]["value"] = Request[para_name];
            }

        }

        private string removeResourceFromJSON(string json, out JObject deserialisedJSON, out JToken json_parentNode, string machineName)
        {
            //List of machines with zero no of instances
            machinesNotRequired.Add(machineName);
            json = editJson.removeResource(json, machineName);
            //removed the undesired resources and updated the JSON object
            deserialisedJSON = JObject.Parse(json);
            json_parentNode = deserialisedJSON["properties"]["parameters"];
            return json;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            //obtain the berer token
            bearerId = AzureJwt.token();
            //Response.Redirect("www.bing.com?" + bearerId);
            Getsubscription();
        }
        protected void Getsubscription()
        {
            //url to fetch the subscription list
            string url= @"https://management.azure.com/subscriptions?api-version=2014-04-01";
            //receive the subscription list in json
            string json = RestResponse.GetJsonResponse(url,bearerId);
            //deserialise the JSON
            JObject jsonObject = JObject.Parse(json);
            var jsonArray = jsonObject["value"];
            //Add subscription name to the dropbox
            foreach (JObject ob in jsonArray)
            {

                Listbox3.Items.Add(new ListItem(ob["displayName"].ToString(), ob["subscriptionId"].ToString()));
            }
        }

    }
}
