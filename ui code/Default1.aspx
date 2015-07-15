<%@ Page Title="Home Page" Language="C#" AutoEventWireup="true" CodeBehind="Default1.aspx.cs" Inherits="Portal._Default" %>

<html>
<head>
    <title>PBPortal - Templates</title>
    <link rel="stylesheet" type="text/css" href="Style/bootstrap.css">
    <link rel="stylesheet" type="text/css" href="Style/style.css">
    <script src="//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="//ajax.aspnetcdn.com/ajax/jQuery.validate/1.11.1/jquery.validate.js" type="text/javascript"></script>
    <script type="text/javascript" src="Scripts/bootstrap.min.js"></script>
    <script>
        $("form").validate({
            showErrors: function (errorMap, errorList) {

                // Clean up any tooltips for valid elements
                $.each(this.validElements(), function (index, element) {
                    var $element = $(element);
                    $element.data("title", "") // Clear the title - there is no error associated anymore
                        .removeClass("error")
                        .tooltip("destroy");
                });

                // Create new tooltips for invalid elements
                $.each(errorList, function (index, error) {
                    var $element = $(error.element);
                    $element.tooltip("destroy") // Destroy any pre-existing tooltip so we can repopulate with new tooltip content
                        .data("title", error.message)
                        .addClass("error")
                        .tooltip(); // Create a new tooltip based on the error message we just set in the title
                });
            },
            submitHandler: function (form) {
                $('.submit').attr("disabled", 'disabled');
                alert('submitting the form')
                form.submit();
            }
            
        });


        function logout() {
            '<%= Session["SubscriptionID"] =""%>';
            '<%= Session["BearerID"] ="" %>';
            '<%= Session["Resource"] ="" %>';
            window.location.assign("default.aspx")
        }


        function cleardev() {
            var devoptions = $('table#<%= DevConfig.ClientID %>').find('input:radio');
            devoptions.removeAttr('checked');
        }
        function clearbuild() {
            var devoptions = $('table#<%= BuildConfig.ClientID %>').find('input:radio');
            devoptions.removeAttr('checked');
        }
        function cleartest() {
            var devoptions = $('table#<%= TestConfig.ClientID %>').find('input:radio');
    devoptions.removeAttr('checked');
}


    </script>

</head>
<body>
    <nav class="navbar navbar-static-top bs-docs-nav area">
        <input type="button" class="btn btn-link navbar-brand" value="PBPortal">
        <input type="button" class="btn btn-link navbar-right navbar-brand" value="Sign Out" onclick="logout()">
    </nav>
    <div>
        <div>
            <form id="form1" runat="server">
                <center>
                <div class="row param area">
                    <center>
                            <h3>Credentials.</h3>
                    <h5>(The credentials will be common for all resources created)</h5></center><br />
                        <label for="Listbox3">Select the subscription you wish to provision the resource group on.</label>
                        <asp:DropDownList ID="Listbox3" runat="server" CssClass="form-control" required="true">
                        </asp:DropDownList><br />
                            <div class="form-group">
                                <label for="adminUsername">Admin Username</label>
                                <input type="text" class="form-control" id="adminUsername" pattern="^[a-z]+$" data-toggle="tooltip" data-placement="bottom" title="Must have only lowercase alphabets" value="newuser" name="adminUsername" required>
                            </div>
                            <div class="form-group">
                                <label for="adminPassword">Admin Password </label>
                                <input type="password" class="form-control" data-toggle="tooltip" data-placement="bottom" title="Must have atleast one uppercase alphabet and one number" id="adminPassword" placeholder="Enter a password" pattern="^\w*(?=\w*\d)(?=\w*[a-z])(?=\w*[A-Z])\w*$" minlength="6" name="adminPassword" required>
                            </div>
                    <div class="form-group">
                        <label for="location">Select location</label>
                        <select class="form-control" id="location" title="Cost varies based on location" name="location">
                            <option value="NorthCentralUS">North Central US</option>
                            <option value="SouthCentralUS">South Central US</option>
                            <option value="WestUS" selected>West US</option>
                            <option value="EastUS">East US</option>
                            <option value="NorthEurope">North Europe</option>
                            <option value="WestEurope">West Europe</option>
                            <option value="EastAsia">East Asia</option>
                            <option value="SoutheastAsia">Southeast Asia</option>
                        </select>
                    </div>
                </div>
                  </center>
                <br />
                <div class="row">
                    <div class="col-xs-6 col-md-4 area" id="dev">
                        <center>
                            <h3>Dev.</h3>
                            <h5>Enter number of virtual machines</h5>
                            <input type="number" min="0" name="devNumberOfInstances" data-msg-number="The input must be a number" data-msg-range="The number of VMs must be 0 to 10" data-rule-number="true" data-rule-range="[0,10]" title="Number of VMs must be a non-negative integer" required id="devNumberOfInstances" class="form-control"><br>
                        </center>
                        <h5>Select the configuration for the virtual machines.</h5>
                        <div>
                            <ul class="configurations">
                                <asp:RadioButtonList ID="DevConfig" runat="server" DataSourceID="DevConfigurations" DataTextField="name" DataValueField="id">
                                </asp:RadioButtonList>
                                <asp:SqlDataSource ID="DevConfigurations" runat="server" ConnectionString="<%$ ConnectionStrings:DevOpsGD_dbConnectionString %>" SelectCommand="SELECT environment_configurations.name, environments.id FROM environment_configurations INNER JOIN environments ON environment_configurations.env_id = environments.id WHERE (environments.name = 'Dev')"></asp:SqlDataSource>
                            </ul>
                            <center>OR<br /></center>
                            Provide the link for your personal configuration.<br />
                            <input class="form-control" type="url" title="Example: https://github.com/prathammehta/DevOps/raw/master/ContosoWebsite.ps1.zip" placeholder="Enter DSC url" name="devmodulesUrl" onfocus="cleardev();"><br />
                            <input class="form-control" type="text" title="Example: DevConfig.ps1\\DevConfig" placeholder="Enter configuration function" name="devconfigurationFunction" onfocus="cleardev();">
                            <br />
                            <br />
                        </div>
                        <div class="row">
                            <div class="form-group col-md-6">
                                <label>
                                    Select VM Size
                                </label>
                                <br />
                                <asp:DropDownList ID="devvmSize" runat="server" DataSourceID="SqlDataSource3" DataTextField="description" DataValueField="name" CssClass="form-control">
                                </asp:DropDownList>
                                <asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString="<%$ ConnectionStrings:DevOpsGD_dbConnectionString21 %>" SelectCommand="SELECT [name], [description] FROM [VMSize]"></asp:SqlDataSource>
                                &nbsp;
                            </div>
                            <div class="form-group col-md-6">
                                <label>
                                    Select Data Disk Size
                                </label>
                                <select class="form-control">
                                    <option>50GB</option>
                                    <option>100GB</option>
                                    <option>250GB</option>
                                    <option>500GB</option>
                                    <option>1TB</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-xs-6 col-md-4 area" id="build">
                        <center>
                            <h3>Build.</h3>
                            <h5>Enter number of virtual machines</h5>
                            <input type="number" min="0" class="form-control"  name="buildNumberOfInstances" data-msg-number="The input must be a number" title="Number of VMs must be a non-negative number" data-msg-range="The number of VMs must be 0 to 10" data-rule-number="true" data-rule-range="[0,10]" required id="buildNumberOfInstances"><br>
                        </center>
                        <h5>Select the configuration for the virtual machines.</h5>
                        <div>
                            <ul class="configurations">
                                <asp:RadioButtonList ID="BuildConfig" runat="server" DataSourceID="SqlDataSource1" DataTextField="name" DataValueField="id">
                                </asp:RadioButtonList>
                                <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:DevOpsGD_dbConnectionString %>" SelectCommand="SELECT environment_configurations.name, environments.id FROM environment_configurations INNER JOIN environments ON environment_configurations.env_id = environments.id WHERE (environments.name = 'Test')"></asp:SqlDataSource>
                            </ul>
                            <center>OR<br /></center>
                            Provide the link for your personal configuration.<br />
                            <input type="url" class="form-control" title="Example: https://github.com/prathammehta/DevOps/raw/master/ContosoWebsite.ps1.zip" placeholder="Enter DSC url" name="build_modules_url" onfocus="clearbuild();"><br />
                            <input type="text" class="form-control" title="Example: DevConfig.ps1\\DevConfig" placeholder="Enter configuration function" name="build_configuration_function" onfocus="clearbuild();">
                            <br />
                            <br />
                        </div>
                        <div class="form-group">
                            <label>Select VM Size</label><br />
                            <asp:DropDownList CssClass="form-control" ID="buildvmSize" runat="server" DataSourceID="SqlDataSource3" DataTextField="description" DataValueField="name">
                            </asp:DropDownList>
                            &nbsp;
                        </div>
                    </div>
                    <div id="test" class="col-xs-6 col-md-4 area">
                        <center>
                            <h3>Test.</h3>
                            <h5>Enter number of virtual machines</h5>
                            <input type="number" class="form-control" min="0"  name="testNumberOfInstances" title="Number of VMs must be a non-negative number" data-msg-number="The input must be a number" data-msg-range="The number of VMs must be 0 to 10" data-rule-number="true" data-rule-range="[0,10]" required id="testNumberOfInstances" aria-pressed="undefined"><br>
                        </center>
                        <h5>Select the configuration for the virtual machines.</h5>
                        <div>
                            <ul class="configurations">
                                <asp:RadioButtonList ID="TestConfig" runat="server" DataSourceID="SqlDataSource2" DataTextField="name" DataValueField="id">
                                </asp:RadioButtonList>
                                <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:DevOpsGD_dbConnectionString %>" SelectCommand="SELECT environment_configurations.name, environments.id FROM environment_configurations INNER JOIN environments ON environment_configurations.env_id = environments.id WHERE (environments.name = 'Build')"></asp:SqlDataSource>
                                <br />
                            </ul>
                            <center>OR<br /></center>
                            Provide the link for your personal configuration.<br />
                            <input type="url" class="form-control" title="Example: https://github.com/prathammehta/DevOps/raw/master/ContosoWebsite.ps1.zip" placeholder="Enter DSC url" name="testmodulesUrl" onfocus="cleartest();"><br />
                            <input type="text" class="form-control" title="Example: DevConfig.ps1\\DevConfig" placeholder="Enter configuration function" name="test_configuration_function" onfocus="cleartest();">
                            <br />
                            <br />
                        </div>
                        <div class="form-group">
                            <label>Select VM Size</label><br />
                            <asp:DropDownList ID="testvmSize" CssClass="form-control" runat="server" DataSourceID="SqlDataSource3" DataTextField="description" DataValueField="name">
                            </asp:DropDownList>
                            &nbsp;
                        </div>
                    </div>
                </div>
                <br>
                <center>
                <div class="row param area">
                        <center><h3>Extensions.</h3></center>
                        <h5>Please note that a <strong>Active Directory</strong>, <strong>Pull server</strong> and <strong>DNS server</strong> will be automatically provisioned for each deployment.</h5>
                        <h5>Please select the checkbox if you wish to provision corresponding extensions.</h5>
                        <div class="checkbox">
                           
                            <label>
                                <input type="checkbox" id="mysqlserver" name="mysqlserver" />
                                SQL Server
                            </label>
                        </div>
                    </div>
                    </center>
                <div class="row">
                    <center>
                        <br />
                       <asp:Button ID="Button1" runat="server" BackColor="#3399FF" Height="38px" OnClick="Button1_Click" Text="Submit" Width="138px" CssClass="submit" />
                        <button type="reset" class="btn btn-danger">Clear</button>
                        <br />
                    </center>
                </div>
            </form>
        </div>
    </div>
</body>
</html>

