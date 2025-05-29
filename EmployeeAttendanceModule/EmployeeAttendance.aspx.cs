using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace EmployeeAttendanceModule
{
    public partial class EmployeeAttendance : System.Web.UI.Page
    {
        string conStr = ConfigurationManager.ConnectionStrings["conn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGrid();
                lblFormTitle.Text = "Employee Attendance Record";
            }
        }

        // Helper method for formatting time values in GridView
        protected string FormatTime(object timeValue)
        {
            if (timeValue == null || timeValue == DBNull.Value)
                return "N/A";

            try
            {
                // If stored as TimeSpan
                if (timeValue is TimeSpan timeSpan)
                {
                    return timeSpan.ToString(@"hh\:mm");
                }

                // If stored as DateTime
                if (timeValue is DateTime dateTime)
                {
                    return dateTime.ToString("HH:mm");
                }

                // If stored as string, try to parse
                string timeStr = timeValue.ToString();
                if (TimeSpan.TryParse(timeStr, out TimeSpan parsedTimeSpan))
                {
                    return parsedTimeSpan.ToString(@"hh\:mm");
                }

                if (DateTime.TryParse(timeStr, out DateTime parsedDateTime))
                {
                    return parsedDateTime.ToString("HH:mm");
                }

                // Return as-is if can't parse
                return timeStr;
            }
            catch (Exception)
            {
                return timeValue.ToString();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                if (!DateTime.TryParse(txtDate.Text, out DateTime date))
                {
                    ShowMessage("Invalid date format. Please enter a valid date.");
                    return;
                }

                if (!TimeSpan.TryParse(txtTimeIn.Text, out TimeSpan timeIn))
                {
                    ShowMessage("Invalid Time In format. Please use HH:mm format.");
                    return;
                }

                if (!TimeSpan.TryParse(txtTimeOut.Text, out TimeSpan timeOut))
                {
                    ShowMessage("Invalid Time Out format. Please use HH:mm format.");
                    return;
                }

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    // Fixed column name from 'Date' to 'AttendanceDate' to match your ASPX
                    string query = @"INSERT INTO EmployeeAttendance (EmployeeID, EmployeeName, AttendanceDate, TimeIn, TimeOut, Remarks)
                                     VALUES (@EmployeeID, @EmployeeName, @AttendanceDate, @TimeIn, @TimeOut, @Remarks)";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@EmployeeID", txtEmployeeID.Text.Trim());
                    cmd.Parameters.AddWithValue("@EmployeeName", txtEmployeeName.Text.Trim());
                    cmd.Parameters.AddWithValue("@AttendanceDate", date);
                    cmd.Parameters.AddWithValue("@TimeIn", timeIn);
                    cmd.Parameters.AddWithValue("@TimeOut", timeOut);
                    cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Attendance record saved successfully.", false);
                ClearForm();
                LoadGrid();
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                if (!DateTime.TryParse(txtDate.Text, out DateTime date))
                {
                    ShowMessage("Invalid date format. Please enter a valid date.");
                    return;
                }

                if (!TimeSpan.TryParse(txtTimeIn.Text, out TimeSpan timeIn))
                {
                    ShowMessage("Invalid Time In format. Please use HH:mm format.");
                    return;
                }

                if (!TimeSpan.TryParse(txtTimeOut.Text, out TimeSpan timeOut))
                {
                    ShowMessage("Invalid Time Out format. Please use HH:mm format.");
                    return;
                }

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    // Fixed column name from 'Date' to 'AttendanceDate'
                    string query = @"UPDATE EmployeeAttendance 
                                     SET EmployeeID = @EmployeeID, EmployeeName = @EmployeeName, AttendanceDate = @AttendanceDate, 
                                         TimeIn = @TimeIn, TimeOut = @TimeOut, Remarks = @Remarks 
                                     WHERE ID = @ID";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@EmployeeID", txtEmployeeID.Text.Trim());
                    cmd.Parameters.AddWithValue("@EmployeeName", txtEmployeeName.Text.Trim());
                    cmd.Parameters.AddWithValue("@AttendanceDate", date);
                    cmd.Parameters.AddWithValue("@TimeIn", timeIn);
                    cmd.Parameters.AddWithValue("@TimeOut", timeOut);
                    cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
                    cmd.Parameters.AddWithValue("@ID", hiddenAttendanceID.Value);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Attendance record updated successfully.", false);
                ClearForm();
                LoadGrid();
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            txtEmployeeID.Text = "";
            txtEmployeeName.Text = "";
            txtDate.Text = "";
            txtTimeIn.Text = "";
            txtTimeOut.Text = "";
            txtRemarks.Text = "";
            hiddenAttendanceID.Value = "";
            btnSave.Visible = true;
            btnUpdate.Visible = false;
            lblFormTitle.Text = "Add New Attendance Record";
            lblMessage.Visible = false;
        }

        private void LoadGrid(string filterQuery = "")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(conStr))
                {
                    // Updated query with proper column names and NULL handling
                    string query = @"SELECT 
                                        ID,
                                        ISNULL(EmployeeID, '') as EmployeeID,
                                        ISNULL(EmployeeName, '') as EmployeeName,
                                        AttendanceDate,
                                        TimeIn,
                                        TimeOut,
                                        ISNULL(Remarks, '') as Remarks
                                    FROM EmployeeAttendance";

                    if (!string.IsNullOrEmpty(filterQuery))
                        query += " WHERE " + filterQuery;

                    query += " ORDER BY AttendanceDate DESC, EmployeeID";

                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvAttendance.DataSource = dt;
                    gvAttendance.DataBind();

                    if (dt.Rows.Count == 0)
                    {
                        ShowMessage("No records found.", false);
                    }
                    else
                    {
                        lblMessage.Visible = false;
                    }
                }
            }
            catch (FormatException ex)
            {
                ShowMessage("Format Error: " + ex.Message + ". Please check your data format.");
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading data: " + ex.Message);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string filter = "";

            if (!string.IsNullOrWhiteSpace(txtSearchEmployeeID.Text))
                filter += $"EmployeeID LIKE '%{txtSearchEmployeeID.Text.Trim()}%'";

            if (!string.IsNullOrWhiteSpace(txtSearchDate.Text))
            {
                if (!string.IsNullOrEmpty(filter))
                    filter += " AND ";

                if (DateTime.TryParse(txtSearchDate.Text, out DateTime searchDate))
                {
                    // Fixed column name from 'Date' to 'AttendanceDate'
                    filter += $"AttendanceDate = '{searchDate:yyyy-MM-dd}'";
                }
                else
                {
                    ShowMessage("Invalid search date format.");
                    return;
                }
            }

            LoadGrid(filter);
        }

        protected void btnShowAll_Click(object sender, EventArgs e)
        {
            txtSearchEmployeeID.Text = "";
            txtSearchDate.Text = "";
            LoadGrid();
        }

        protected void gvAttendance_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRecord")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = gvAttendance.Rows[rowIndex];

                hiddenAttendanceID.Value = gvAttendance.DataKeys[rowIndex].Value.ToString();

                // Get values safely to avoid format exceptions
                txtEmployeeID.Text = GetCellText(row.Cells[1]);
                txtEmployeeName.Text = GetCellText(row.Cells[2]);

                // Get date from the TemplateField
                Label lblDate = (Label)row.FindControl("lblDate");
                if (lblDate != null)
                {
                    txtDate.Text = lblDate.Text;
                }

                // Get time values - they're now in TemplateFields, so we need to get them from DataKeys or re-query
                DataTable dt = GetRecordById(Convert.ToInt32(hiddenAttendanceID.Value));
                if (dt.Rows.Count > 0)
                {
                    DataRow dataRow = dt.Rows[0];

                    // Format time values properly
                    if (dataRow["TimeIn"] != DBNull.Value)
                    {
                        if (dataRow["TimeIn"] is TimeSpan timeIn)
                            txtTimeIn.Text = timeIn.ToString(@"hh\:mm");
                        else
                            txtTimeIn.Text = dataRow["TimeIn"].ToString();
                    }

                    if (dataRow["TimeOut"] != DBNull.Value)
                    {
                        if (dataRow["TimeOut"] is TimeSpan timeOut)
                            txtTimeOut.Text = timeOut.ToString(@"hh\:mm");
                        else
                            txtTimeOut.Text = dataRow["TimeOut"].ToString();
                    }

                    txtRemarks.Text = dataRow["Remarks"].ToString();
                }

                btnSave.Visible = false;
                btnUpdate.Visible = true;
                lblFormTitle.Text = "Edit Attendance Record";
                lblMessage.Visible = false;
            }
            else if (e.CommandName == "DeleteRecord")
            {
                int id = Convert.ToInt32(e.CommandArgument);

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    string query = "DELETE FROM EmployeeAttendance WHERE ID = @ID";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@ID", id);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Record deleted successfully.", false);
                LoadGrid();
            }
        }

        // Helper method to get cell text safely
        private string GetCellText(TableCell cell)
        {
            return cell.Text == "&nbsp;" ? "" : cell.Text;
        }

        // Helper method to get a specific record by ID
        private DataTable GetRecordById(int id)
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                string query = "SELECT * FROM EmployeeAttendance WHERE ID = @ID";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@ID", id);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        protected void cvTimeOut_ServerValidate(object source, ServerValidateEventArgs args)
        {
            if (TimeSpan.TryParse(txtTimeIn.Text, out TimeSpan timeIn) && TimeSpan.TryParse(txtTimeOut.Text, out TimeSpan timeOut))
            {
                args.IsValid = timeOut > timeIn;
            }
            else
            {
                args.IsValid = false;
            }
        }

        private void ShowMessage(string message, bool isError = true)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.Red : System.Drawing.Color.Green;
            lblMessage.Visible = true;
        }
    }
}