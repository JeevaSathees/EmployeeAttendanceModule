<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeAttendance.aspx.cs" Inherits="EmployeeAttendanceModule.EmployeeAttendance" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Employee Attendance</title>
    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f8f9fa; /* lighter gray */
        }
        .form-section {
            background-color: #fff;
            border-radius: 0.5rem;
            padding: 2rem;
            box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,.075);
        }
        .gridview-container {
            margin-top: 2rem;
        }
        /* Custom for GridView table */
        .table thead th {
            background-color: #e9ecef;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="py-5">
        <div class="container">
            <div class="form-section shadow-sm">
                <h2 class="mb-4 text-primary text-center">
                    <asp:Label ID="lblFormTitle" runat="server" Text="Attendance Record"></asp:Label>
                </h2>

                <asp:Label ID="lblMessage" runat="server" CssClass="text-danger mb-3 d-block" Visible="false"></asp:Label>

                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <asp:Label Text="Employee ID:" AssociatedControlID="txtEmployeeID" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtEmployeeID" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-6">
                        <asp:Label Text="Employee Name:" AssociatedControlID="txtEmployeeName" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtEmployeeName" runat="server" CssClass="form-control" />
                    </div>
                </div>

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <asp:Label Text="Date:" AssociatedControlID="txtDate" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtDate" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>
                    <div class="col-md-4">
                        <asp:Label Text="Time In:" AssociatedControlID="txtTimeIn" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtTimeIn" runat="server" Placeholder="HH:mm" CssClass="form-control" />
                    </div>
                    <div class="col-md-4">
                        <asp:Label Text="Time Out:" AssociatedControlID="txtTimeOut" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtTimeOut" runat="server" Placeholder="HH:mm" CssClass="form-control" />
                        <asp:CustomValidator ID="cvTimeOut" runat="server" ControlToValidate="txtTimeOut"
                            OnServerValidate="cvTimeOut_ServerValidate" ErrorMessage="Time Out must be greater than Time In" 
                            CssClass="text-danger mt-1 d-block" Display="Dynamic" />
                    </div>
                </div>

                <div class="mb-4">
                    <asp:Label Text="Remarks:" AssociatedControlID="txtRemarks" runat="server" CssClass="form-label" />
                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="3" Columns="30" CssClass="form-control" />
                    <asp:HiddenField ID="hiddenAttendanceID" runat="server" />
                </div>

                <div class="mb-4 d-flex gap-2 flex-wrap">
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_Click" />
                    <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn btn-warning" OnClick="btnUpdate_Click" Visible="false" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="btnCancel_Click" />
                </div>

                <div class="row g-3 align-items-end">
                    <div class="col-md-5">
                        <asp:Label Text="Search by Employee ID:" AssociatedControlID="txtSearchEmployeeID" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtSearchEmployeeID" runat="server" CssClass="form-control" />
                    </div>
                    <div class="col-md-4">
                        <asp:Label Text="Date:" AssociatedControlID="txtSearchDate" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtSearchDate" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>
                    <div class="col-md-3 d-flex gap-2">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary w-100" OnClick="btnSearch_Click" />
                        <asp:Button ID="btnShowAll" runat="server" Text="Show All" CssClass="btn btn-info w-100" OnClick="btnShowAll_Click" />
                    </div>
                </div>
            </div>

            <div class="gridview-container mt-5">
                <div class="table-responsive shadow-sm rounded">
                    <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="False" DataKeyNames="ID"
                        OnRowCommand="gvAttendance_RowCommand" CssClass="table table-striped table-bordered align-middle mb-0" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" Visible="false" />
                            <asp:BoundField DataField="EmployeeID" HeaderText="Employee ID" />
                            <asp:BoundField DataField="EmployeeName" HeaderText="Employee Name" />

                            <asp:TemplateField HeaderText="Date">
                                <ItemTemplate>
                                    <%# Eval("AttendanceDate") != DBNull.Value ? 
                                        Convert.ToDateTime(Eval("AttendanceDate")).ToString("yyyy-MM-dd") : 
                                        "N/A" %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Time In">
                                <ItemTemplate>
                                    <%# Eval("TimeIn") != DBNull.Value ? 
                                        FormatTime(Eval("TimeIn")) : 
                                        "N/A" %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Time Out">
                                <ItemTemplate>
                                    <%# Eval("TimeOut") != DBNull.Value ? 
                                        FormatTime(Eval("TimeOut")) : 
                                        "N/A" %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" />

                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" 
                                        CommandName="EditRecord" 
                                        CommandArgument='<%# Container.DataItemIndex %>' 
                                        Text="Edit" CssClass="btn btn-sm btn-outline-primary" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkDelete" runat="server" 
                                        CommandName="DeleteRecord" 
                                        CommandArgument='<%# Eval("ID") %>' 
                                        Text="Delete" CssClass="btn btn-sm btn-outline-danger"
                                        OnClientClick="return confirm('Are you sure you want to delete this record?');" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
