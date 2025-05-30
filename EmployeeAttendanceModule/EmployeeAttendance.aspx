<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeAttendance.aspx.cs" Inherits="EmployeeAttendanceModule.EmployeeAttendance" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Employee Attendance Portal</title>
    <!-- Bootstrap 5.3.3 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
            --success-gradient: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            --warning-gradient: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
            --danger-gradient: linear-gradient(135deg, #ff8a80 0%, #ff5722 100%);
            --info-gradient: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
            --glass-bg: rgba(255, 255, 255, 0.1);
            --glass-border: rgba(255, 255, 255, 0.2);
        }

        * {
            transition: all 0.3s ease;
        }

        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(-45deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4);
            background-size: 400% 400%;
            animation: gradientShift 15s ease infinite;
            min-height: 100vh;
            overflow-x: hidden;
        }

        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .floating-shapes {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: -1;
        }

        .shape {
            position: absolute;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            animation: float 20s infinite;
        }

        .shape:nth-child(1) {
            width: 100px;
            height: 100px;
            top: 10%;
            left: 10%;
            animation-delay: 0s;
        }

        .shape:nth-child(2) {
            width: 150px;
            height: 150px;
            top: 70%;
            right: 10%;
            animation-delay: -5s;
        }

        .shape:nth-child(3) {
            width: 80px;
            height: 80px;
            top: 40%;
            left: 80%;
            animation-delay: -10s;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); opacity: 0.3; }
            50% { transform: translateY(-20px) rotate(180deg); opacity: 0.8; }
        }

        .container {
            max-width: 1400px;
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            border-radius: 2rem;
            padding: 2.5rem;
            margin-top: 2rem;
            box-shadow: 
                0 8px 32px rgba(31, 38, 135, 0.37),
                inset 0 1px 0 rgba(255, 255, 255, 0.3);
            animation: slideUp 0.8s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-section,
        .gridview-container,
        #reportContainer {
            background: var(--glass-bg);
            backdrop-filter: blur(15px);
            border: 1px solid var(--glass-border);
            border-radius: 1.5rem;
            padding: 2.5rem;
            margin-top: 2rem;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
            animation: fadeInUp 0.6s ease-out forwards;
            opacity: 0;
            transform: translateY(30px);
        }

        .form-section { animation-delay: 0.2s; }
        .gridview-container { animation-delay: 0.4s; }
        #reportContainer { animation-delay: 0.6s; }

        @keyframes fadeInUp {
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .section-title {
            font-size: 2.2rem;
            font-weight: 700;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-align: center;
            margin-bottom: 2rem;
            position: relative;
            animation: titleGlow 2s ease-in-out infinite alternate;
        }

        @keyframes titleGlow {
            from { filter: drop-shadow(0 0 5px rgba(255, 107, 107, 0.3)); }
            to { filter: drop-shadow(0 0 15px rgba(255, 107, 107, 0.6)); }
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 4px;
            background: var(--primary-gradient);
            border-radius: 2px;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { width: 60px; opacity: 1; }
            50% { width: 100px; opacity: 0.7; }
        }

        .form-label {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.8rem;
            position: relative;
            display: inline-block;
        }

        .form-control {
            border: 2px solid transparent;
            border-radius: 12px;
            padding: 12px 16px;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }

        .form-control:focus {
            border-color: #ff6b6b;
            box-shadow: 
                0 0 0 0.25rem rgba(255, 107, 107, 0.25),
                0 4px 16px rgba(255, 107, 107, 0.15);
            transform: translateY(-2px);
            background: rgba(255, 255, 255, 0.95);
        }

        .form-control:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .btn {
            border: none;
            border-radius: 12px;
            padding: 12px 24px;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.9rem;
            letter-spacing: 0.5px;
            position: relative;
            overflow: hidden;
            transform: translateY(0);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
            transition: left 0.5s;
        }

        .btn:hover::before {
            left: 100%;
        }

        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
        }

        .btn:active {
            transform: translateY(-1px);
        }

        .btn-success {
            background: var(--success-gradient);
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .btn-success:hover {
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
        }

        .btn-warning {
            background: var(--warning-gradient);
            color: #8b4513;
            box-shadow: 0 4px 15px rgba(255, 183, 107, 0.3);
        }

        .btn-warning:hover {
            box-shadow: 0 8px 25px rgba(255, 183, 107, 0.4);
        }

        .btn-primary {
            background: var(--primary-gradient);
            box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
        }

        .btn-primary:hover {
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.4);
        }

        .btn-outline-info {
            border: 2px solid #74b9ff;
            color: #74b9ff;
            background: transparent;
            transition: all 0.3s ease;
        }

        .btn-outline-info:hover {
            background: #74b9ff;
            color: white;
            transform: translateY(-3px);
        }

        .btn-outline-primary {
            border: 2px solid #ff6b6b;
            color: #ff6b6b;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
        }

        .btn-outline-primary:hover {
            background: #ff6b6b;
            color: white;
            transform: scale(1.05);
        }

        .btn-outline-danger {
            border: 2px solid #ff8a80;
            color: #ff8a80;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
        }

        .btn-outline-danger:hover {
            background: #ff8a80;
            color: white;
            transform: scale(1.05);
        }

        .table {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
        }

        .table thead th {
            background: var(--primary-gradient);
            color: white;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.9rem;
            letter-spacing: 0.5px;
            border: none;
            padding: 1rem;
        }

        .table tbody tr {
            transition: all 0.3s ease;
        }

        .table tbody tr:hover {
            background: rgba(255, 107, 107, 0.1);
            transform: scale(1.01);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .table tbody td {
            padding: 1rem;
            border: none;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        .loading-spinner {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 9999;
        }

        .spinner {
            width: 60px;
            height: 60px;
            border: 4px solid rgba(255, 107, 107, 0.3);
            border-top: 4px solid #ff6b6b;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .success-message {
            background: var(--success-gradient);
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            animation: slideDown 0.5s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .card-hover {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .card-hover:hover {
            transform: translateY(-5px) scale(1.02);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
        }

        /* Icon animations */
        .btn i {
            margin-right: 8px;
            transition: transform 0.3s ease;
        }

        .btn:hover i {
            transform: scale(1.2) rotate(5deg);
        }

        /* Responsive enhancements */
        @media (max-width: 768px) {
            .container {
                margin: 1rem;
                padding: 1.5rem;
            }
            
            .section-title {
                font-size: 1.8rem;
            }
            
            .form-section,
            .gridview-container,
            #reportContainer {
                padding: 1.5rem;
            }
        }

        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
        }

        ::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.1);
        }

        ::-webkit-scrollbar-thumb {
            background: var(--primary-gradient);
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(135deg, #ee5a6f 0%, #ff6b6b 100%);
        }
    </style>
</head>
<body>
    <div class="floating-shapes">
        <div class="shape"></div>
        <div class="shape"></div>
        <div class="shape"></div>
    </div>

    <div class="loading-spinner" id="loadingSpinner">
        <div class="spinner"></div>
    </div>

    <form id="form1" runat="server" class="py-4">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="container card-hover">

            <!-- Form Section -->
            <div class="form-section">
                <h2 class="section-title">
                    <i class="fas fa-user-clock"></i>
                    Employee Attendance Portal
                </h2>

                <asp:Label ID="lblMessage" runat="server" CssClass="success-message d-block" Visible="false" />

                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <asp:Label Text="Employee ID:" AssociatedControlID="txtEmployeeID" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtEmployeeID" runat="server" CssClass="form-control" placeholder="Enter employee ID..." />
                    </div>
                    <div class="col-md-6">
                        <asp:Label Text="Employee Name:" AssociatedControlID="txtEmployeeName" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtEmployeeName" runat="server" CssClass="form-control" placeholder="Enter full name..." />
                    </div>
                </div>

                <div class="row g-4 mb-4">
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
                            OnServerValidate="cvTimeOut_ServerValidate" CssClass="text-danger mt-2 d-block" Display="Dynamic" />
                    </div>
                </div>

                <div class="mb-4">
                    <asp:Label Text="Remarks:" AssociatedControlID="txtRemarks" runat="server" CssClass="form-label" />
                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" 
                        placeholder="Add any additional notes or comments..." />
                    <asp:HiddenField ID="hiddenAttendanceID" runat="server" />
                </div>

                <div class="mb-4 d-flex gap-3 flex-wrap justify-content-center">
                    <asp:Button ID="btnSave" runat="server" Text="Save Record" CssClass="btn btn-success" OnClick="btnSave_Click" />
                    <asp:Button ID="btnUpdate" runat="server" Text="Update Record" CssClass="btn btn-warning" Visible="false" OnClick="btnUpdate_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="btnCancel_Click" />
                </div>

                <!-- Search Section -->
                <div class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <asp:Label Text="Search by Employee ID:" AssociatedControlID="txtSearchEmployeeID" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtSearchEmployeeID" runat="server" CssClass="form-control" placeholder="Enter ID to search..." />
                    </div>
                    <div class="col-md-4">
                        <asp:Label Text="Filter by Date:" AssociatedControlID="txtSearchDate" runat="server" CssClass="form-label" />
                        <asp:TextBox ID="txtSearchDate" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>
                    <div class="col-md-4 d-flex gap-2">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary flex-fill" OnClick="btnSearch_Click" />
                        <asp:Button ID="btnShowAll" runat="server" Text="Show All" CssClass="btn btn-outline-info flex-fill" OnClick="btnShowAll_Click" />
                        <asp:Button ID="btnGenerateReport" runat="server" Text="Report" CssClass="btn btn-success flex-fill" OnClick="btnGenerateReport_Click" />
                    </div>
                </div>
            </div>

            <!-- GridView Section -->
            <div class="gridview-container">
                <h2 class="section-title">
                    <i class="fas fa-table"></i>
                    Attendance Records
                </h2>
                <div class="table-responsive">
                    <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="False" DataKeyNames="ID"
                        OnRowCommand="gvAttendance_RowCommand"
                        CssClass="table table-hover align-middle text-center" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" Visible="false" />
                            <asp:BoundField DataField="EmployeeID" HeaderText="Employee ID" />
                            <asp:BoundField DataField="EmployeeName" HeaderText="Employee Name" />
                            <asp:TemplateField HeaderText="Date">
                                <ItemTemplate>
                                    <%# Eval("AttendanceDate") != DBNull.Value ? Convert.ToDateTime(Eval("AttendanceDate")).ToString("yyyy-MM-dd") : "N/A" %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Time In">
                                <ItemTemplate>
                                    <%# Eval("TimeIn") != DBNull.Value ? FormatTime(Eval("TimeIn")) : "N/A" %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Time Out">
                                <ItemTemplate>
                                    <%# Eval("TimeOut") != DBNull.Value ? FormatTime(Eval("TimeOut")) : "N/A" %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditRecord"
                                        CommandArgument='<%# Container.DataItemIndex %>'
                                        Text="Edit" CssClass="btn btn-sm btn-outline-primary me-2" />
                                    <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteRecord"
                                        CommandArgument='<%# Container.DataItemIndex %>'
                                        Text="Delete" CssClass="btn btn-sm btn-outline-danger"
                                        OnClientClick="return confirm('Are you sure you want to delete this record?');" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- ReportViewer Section -->
            <div id="reportContainer">
                <h2 class="section-title">
                    <i class="fas fa-chart-bar"></i>
                    Attendance Analytics
                </h2>
                <rsweb:ReportViewer ID="ReportViewer1" runat="server" Width="100%" Height="600px"
                    ProcessingMode="Local" Font-Names="Segoe UI" Font-Size="10pt" />
            </div>

        </div>
    </form>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Enhanced form interactions
        document.addEventListener('DOMContentLoaded', function () {
            // Show loading spinner on form submissions
            const buttons = document.querySelectorAll('.btn');
            buttons.forEach(button => {
                button.addEventListener('click', function (e) {
                    if (this.type === 'submit') {
                        setTimeout(() => {
                            document.getElementById('loadingSpinner').style.display = 'block';
                        }, 100);
                    }
                });
            });

            // Add focus animations to form controls
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.parentElement.style.transform = 'scale(1.02)';
                });

                input.addEventListener('blur', function () {
                    this.parentElement.style.transform = 'scale(1)';
                });
            });

            // Auto-hide messages after 5 seconds
            const messages = document.querySelectorAll('.success-message');
            messages.forEach(message => {
                if (message.style.display !== 'none') {
                    setTimeout(() => {
                        message.style.animation = 'slideUp 0.5s ease-out forwards';
                        setTimeout(() => {
                            message.style.display = 'none';
                        }, 500);
                    }, 5000);
                }
            });

            // Enhanced table row interactions
            const tableRows = document.querySelectorAll('.table tbody tr');
            tableRows.forEach(row => {
                row.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateX(5px)';
                });

                row.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateX(0)';
                });
            });

            // Add ripple effect to buttons
            buttons.forEach(button => {
                button.addEventListener('click', function (e) {
                    const ripple = document.createElement('span');
                    const rect = this.getBoundingClientRect();
                    const size = Math.max(rect.width, rect.height);
                    const x = e.clientX - rect.left - size / 2;
                    const y = e.clientY - rect.top - size / 2;

                    ripple.style.cssText = `
                        width: ${size}px;
                        height: ${size}px;
                        left: ${x}px;
                        top: ${y}px;
                        position: absolute;
                        border-radius: 50%;
                        background: rgba(255, 255, 255, 0.4);
                        pointer-events: none;
                        animation: ripple 0.6s ease-out;
                    `;

                    this.style.position = 'relative';
                    this.style.overflow = 'hidden';
                    this.appendChild(ripple);

                    setTimeout(() => {
                        ripple.remove();
                    }, 600);
                });
            });
        });

        // Add ripple animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes ripple {
                from {
                    transform: scale(0);
                    opacity: 1;
                }
                to {
                    transform: scale(2);
                    opacity: 0;
                }
            }
            
            @keyframes slideUp {
                to {
                    opacity: 0;
                    transform: translateY(-20px);
                }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>