using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Reporting.WebForms;

namespace EmployeeAttendanceModule
{
    public partial class EmployeeAttendance : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["conn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGrid();
                btnUpdate.Visible = false;
                lblMessage.Visible = false;
            }
        }

        private void LoadGrid(string employeeId = null, DateTime? date = null)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT * FROM EmployeeAttendance WHERE 1=1";

                if (!string.IsNullOrEmpty(employeeId))
                    query += " AND EmployeeID = @EmployeeID";

                if (date.HasValue)
                    query += " AND AttendanceDate = @AttendanceDate";

                SqlCommand cmd = new SqlCommand(query, con);

                if (!string.IsNullOrEmpty(employeeId))
                    cmd.Parameters.Add("@EmployeeID", SqlDbType.NVarChar, 50).Value = employeeId;

                if (date.HasValue)
                    cmd.Parameters.Add("@AttendanceDate", SqlDbType.Date).Value = date.Value.Date;

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();

                da.Fill(dt);

                gvAttendance.DataSource = dt;
                gvAttendance.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                if (!CheckOverlap(txtEmployeeID.Text.Trim(), txtDate.Text.Trim(), txtTimeIn.Text.Trim(), txtTimeOut.Text.Trim(), null))
                {
                    lblMessage.Text = "Attendance record overlaps with existing entries.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Visible = true;
                    return;
                }

                if (!DateTime.TryParse(txtDate.Text.Trim(), out DateTime attendanceDate) ||
                    !TimeSpan.TryParse(txtTimeIn.Text.Trim(), out TimeSpan timeIn) ||
                    !TimeSpan.TryParse(txtTimeOut.Text.Trim(), out TimeSpan timeOut))
                {
                    lblMessage.Text = "Invalid date or time format.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Visible = true;
                    return;
                }

                using (SqlConnection con = new SqlConnection(connString))
                {
                    string query = @"INSERT INTO EmployeeAttendance 
                                     (EmployeeID, EmployeeName, AttendanceDate, TimeIn, TimeOut, Remarks) 
                                     VALUES (@EmployeeID, @EmployeeName, @AttendanceDate, @TimeIn, @TimeOut, @Remarks)";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.Add("@EmployeeID", SqlDbType.NVarChar, 50).Value = txtEmployeeID.Text.Trim();
                    cmd.Parameters.Add("@EmployeeName", SqlDbType.NVarChar, 100).Value = txtEmployeeName.Text.Trim();
                    cmd.Parameters.Add("@AttendanceDate", SqlDbType.Date).Value = attendanceDate.Date;
                    cmd.Parameters.Add("@TimeIn", SqlDbType.Time).Value = timeIn;
                    cmd.Parameters.Add("@TimeOut", SqlDbType.Time).Value = timeOut;
                    cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar, 255).Value = txtRemarks.Text.Trim();

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }

                ClearForm();
                LoadGrid();
                lblMessage.Text = "Record saved successfully.";
                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Visible = true;
            }
        }

        protected string FormatTime(object timeObj)
        {
            if (timeObj == null || timeObj == DBNull.Value)
                return "N/A";

            if (timeObj is TimeSpan ts)
            {
                // Format TimeSpan as HH:mm
                return ts.ToString(@"hh\:mm");
            }

            // In case time is stored as DateTime or string, try to parse and format:
            if (TimeSpan.TryParse(timeObj.ToString(), out var parsedTime))
            {
                return parsedTime.ToString(@"hh\:mm");
            }

            if (DateTime.TryParse(timeObj.ToString(), out var dt))
            {
                return dt.ToString("HH:mm");
            }

            return "N/A";
        }


        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                if (!int.TryParse(hiddenAttendanceID.Value, out int id))
                {
                    lblMessage.Text = "Invalid record ID.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Visible = true;
                    return;
                }

                if (!CheckOverlap(txtEmployeeID.Text.Trim(), txtDate.Text.Trim(), txtTimeIn.Text.Trim(), txtTimeOut.Text.Trim(), id))
                {
                    lblMessage.Text = "Attendance record overlaps with existing entries.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Visible = true;
                    return;
                }

                if (!DateTime.TryParse(txtDate.Text.Trim(), out DateTime attendanceDate) ||
                    !TimeSpan.TryParse(txtTimeIn.Text.Trim(), out TimeSpan timeIn) ||
                    !TimeSpan.TryParse(txtTimeOut.Text.Trim(), out TimeSpan timeOut))
                {
                    lblMessage.Text = "Invalid date or time format.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Visible = true;
                    return;
                }

                using (SqlConnection con = new SqlConnection(connString))
                {
                    string query = @"UPDATE EmployeeAttendance SET 
                                     EmployeeID = @EmployeeID, 
                                     EmployeeName = @EmployeeName, 
                                     AttendanceDate = @AttendanceDate, 
                                     TimeIn = @TimeIn, 
                                     TimeOut = @TimeOut, 
                                     Remarks = @Remarks 
                                     WHERE ID = @ID";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.Add("@EmployeeID", SqlDbType.NVarChar, 50).Value = txtEmployeeID.Text.Trim();
                    cmd.Parameters.Add("@EmployeeName", SqlDbType.NVarChar, 100).Value = txtEmployeeName.Text.Trim();
                    cmd.Parameters.Add("@AttendanceDate", SqlDbType.Date).Value = attendanceDate.Date;
                    cmd.Parameters.Add("@TimeIn", SqlDbType.Time).Value = timeIn;
                    cmd.Parameters.Add("@TimeOut", SqlDbType.Time).Value = timeOut;
                    cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar, 255).Value = txtRemarks.Text.Trim();
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value = id;

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }

                ClearForm();
                LoadGrid();
                btnSave.Visible = true;
                btnUpdate.Visible = false;
                lblMessage.Text = "Record updated successfully.";
                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Visible = true;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
            btnSave.Visible = true;
            btnUpdate.Visible = false;
            lblMessage.Visible = false;
        }

        protected void gvAttendance_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRecord" || e.CommandName == "DeleteRecord")
            {
                if (int.TryParse(e.CommandArgument.ToString(), out int rowIndex))
                {
                    // Ensure rowIndex is within range
                    if (rowIndex >= 0 && rowIndex < gvAttendance.DataKeys.Count)
                    {
                        int id = Convert.ToInt32(gvAttendance.DataKeys[rowIndex].Value);

                        if (e.CommandName == "EditRecord")
                        {
                            LoadRecordForEdit(id);
                        }
                        else if (e.CommandName == "DeleteRecord")
                        {
                            DeleteRecord(id);
                        }
                    }
                    else
                    {
                        lblMessage.Text = "Invalid row selection.";
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Visible = true;
                    }
                }
                else
                {
                    lblMessage.Text = "Invalid command argument.";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Visible = true;
                }
            }
        }

        protected void gvAttendance_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (TimeSpan.TryParse(DataBinder.Eval(e.Row.DataItem, "TimeIn")?.ToString(), out TimeSpan timeIn) &&
                    TimeSpan.TryParse(DataBinder.Eval(e.Row.DataItem, "TimeOut")?.ToString(), out TimeSpan timeOut))
                {
                    TimeSpan lateThreshold = new TimeSpan(9, 0, 0); // 9:00 AM
                    TimeSpan earlyThreshold = new TimeSpan(17, 0, 0); // 5:00 PM

                    if (timeIn > lateThreshold)
                    {
                        e.Row.Cells[4].BackColor = System.Drawing.Color.LightCoral; // Highlight TimeIn cell
                    }

                    if (timeOut < earlyThreshold)
                    {
                        e.Row.Cells[5].BackColor = System.Drawing.Color.LightYellow; // Highlight TimeOut cell
                    }
                }
            }
        }

        private void LoadRecordForEdit(int id)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT * FROM EmployeeAttendance WHERE ID = @ID";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = id;

                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        txtEmployeeID.Text = reader["EmployeeID"].ToString();
                        txtEmployeeName.Text = reader["EmployeeName"].ToString();
                        txtDate.Text = Convert.ToDateTime(reader["AttendanceDate"]).ToString("yyyy-MM-dd");
                        txtTimeIn.Text = ((TimeSpan)reader["TimeIn"]).ToString(@"hh\:mm");
                        txtTimeOut.Text = ((TimeSpan)reader["TimeOut"]).ToString(@"hh\:mm");
                        txtRemarks.Text = reader["Remarks"].ToString();

                        hiddenAttendanceID.Value = id.ToString();
                    }
                }
                con.Close();
            }

            btnSave.Visible = false;
            btnUpdate.Visible = true;
            lblMessage.Visible = false;
        }

        private void DeleteRecord(int id)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "DELETE FROM EmployeeAttendance WHERE ID = @ID";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = id;

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
            }

            LoadGrid();
            lblMessage.Text = "Record deleted successfully.";
            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Visible = true;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string empId = txtSearchEmployeeID.Text.Trim();
            DateTime? date = null;
            if (DateTime.TryParse(txtSearchDate.Text.Trim(), out DateTime dt))
                date = dt;

            gvAttendance.PageIndex = 0; // Reset to first page on search
            LoadGrid(empId == string.Empty ? null : empId, date);
            lblMessage.Visible = false;
        }

        protected void btnShowAll_Click(object sender, EventArgs e)
        {
            txtSearchEmployeeID.Text = string.Empty;
            txtSearchDate.Text = string.Empty;
            gvAttendance.PageIndex = 0;
            LoadGrid();
            lblMessage.Visible = false;
        }

        protected void gvAttendance_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAttendance.PageIndex = e.NewPageIndex;
            // Reload with current search filters if needed, else load all
            string empId = txtSearchEmployeeID.Text.Trim();
            DateTime? date = null;
            if (DateTime.TryParse(txtSearchDate.Text.Trim(), out DateTime dt))
                date = dt;

            LoadGrid(empId == string.Empty ? null : empId, date);
        }

        protected void cvTimeOut_ServerValidate(object source, ServerValidateEventArgs args)
        {
            if (TimeSpan.TryParse(txtTimeIn.Text, out TimeSpan timeIn) &&
                TimeSpan.TryParse(txtTimeOut.Text, out TimeSpan timeOut))
            {
                args.IsValid = timeOut > timeIn;
            }
            else
            {
                args.IsValid = false;
            }
        }

        private bool CheckOverlap(string employeeId, string dateStr, string timeInStr, string timeOutStr, int? excludeId)
        {
            if (!DateTime.TryParse(dateStr, out DateTime date)) return false;
            if (!TimeSpan.TryParse(timeInStr, out TimeSpan timeIn)) return false;
            if (!TimeSpan.TryParse(timeOutStr, out TimeSpan timeOut)) return false;

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    SELECT COUNT(*) FROM EmployeeAttendance 
                    WHERE EmployeeID = @EmployeeID 
                    AND AttendanceDate = @Date
                    AND (@ExcludeID IS NULL OR ID != @ExcludeID)
                    AND (
                        (@TimeIn BETWEEN TimeIn AND TimeOut)
                        OR (@TimeOut BETWEEN TimeIn AND TimeOut)
                        OR (TimeIn BETWEEN @TimeIn AND @TimeOut)
                        OR (TimeOut BETWEEN @TimeIn AND @TimeOut)
                    )";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.Add("@EmployeeID", SqlDbType.NVarChar, 50).Value = employeeId;
                cmd.Parameters.Add("@Date", SqlDbType.Date).Value = date.Date;
                cmd.Parameters.Add("@TimeIn", SqlDbType.Time).Value = timeIn;
                cmd.Parameters.Add("@TimeOut", SqlDbType.Time).Value = timeOut;
                if (excludeId.HasValue)
                    cmd.Parameters.Add("@ExcludeID", SqlDbType.Int).Value = excludeId.Value;
                else
                    cmd.Parameters.Add("@ExcludeID", SqlDbType.Int).Value = DBNull.Value;

                con.Open();
                int count = (int)cmd.ExecuteScalar();
                con.Close();

                return count == 0;
            }
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
            lblMessage.Visible = false;
        }

        protected void btnGenerateReport_Click(object sender, EventArgs e)
        {
            try
            {
                // Fetch data to bind to report - adjust this method to your data fetching logic
                DataTable dtAttendance = GetAttendanceDataForReport();

                if (dtAttendance == null || dtAttendance.Rows.Count == 0)
                {
                    lblMessage.Text = "No records to display in report.";
                    lblMessage.Visible = true;
                    ReportViewer1.Visible = false;
                    return;
                }

                lblMessage.Visible = false;
                ReportViewer1.Visible = true;

                ReportViewer1.Reset();
                ReportViewer1.ProcessingMode = ProcessingMode.Local;
                ReportViewer1.LocalReport.ReportPath = Server.MapPath("Report1.rdlc");

                // Clear previous data sources
                ReportViewer1.LocalReport.DataSources.Clear();

                // Provide the data source for the report
                ReportDataSource rds = new ReportDataSource("DataSet1", dtAttendance);
                ReportViewer1.LocalReport.DataSources.Add(rds);

                ReportViewer1.LocalReport.Refresh();
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error generating report: " + ex.Message;
                lblMessage.Visible = true;
                ReportViewer1.Visible = false;
            }
        }

        // Example method to fetch data for the report (replace with your actual data access)
        private DataTable GetAttendanceDataForReport()
        {
            DataTable dt = new DataTable();

            // Assuming you have a method GetConnection() returning SqlConnection
            using (SqlConnection con = GetConnection())
            {
                string query = "SELECT ID, EmployeeID, EmployeeName, AttendanceDate, TimeIn, TimeOut, Remarks FROM EmployeeAttendance";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            return dt;
        }

        // Example SqlConnection method (adjust connection string accordingly)
        private SqlConnection GetConnection()
        {
            string connStr = ConfigurationManager.ConnectionStrings["conn"].ConnectionString;
            return new SqlConnection(connStr);
        }

        protected void gvAttendance_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}