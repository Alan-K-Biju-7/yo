// Configuration
const API_BASE_URL = "http://localhost:8000/api";
let adminToken = localStorage.getItem("adminToken");
let adminName = localStorage.getItem("adminName");

// Initialize app
document.addEventListener("DOMContentLoaded", () => {
    if (adminToken) {
        showDashboard();
        document.getElementById("adminName").textContent = `Logged in as: ${adminName}`;
    } else {
        checkAdminExists();
    }

    // Setup event listeners
    setupLoginForm();
    setupInitAdminForm();
    setupTabs();
    setupFormHandlers();
    setupLogout();
});

// ==================== LOGIN & INIT ==================== 

function checkAdminExists() {
    showLoginScreen();
}

function setupLoginForm() {
    document.getElementById("loginForm").addEventListener("submit", async (e) => {
        e.preventDefault();
        const username = document.getElementById("username").value;
        const password = document.getElementById("password").value;
        const errorDiv = document.getElementById("loginError");
        
        try {
            errorDiv.style.display = "none";
            const response = await fetch(`${API_BASE_URL}/admin/login`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ username, password })
            });

            if (response.ok) {
                const data = await response.json();
                adminToken = data.access_token;
                adminName = data.admin_name;
                localStorage.setItem("adminToken", adminToken);
                localStorage.setItem("adminName", adminName);
                showDashboard();
                document.getElementById("adminName").textContent = `Logged in as: ${adminName}`;
                document.getElementById("loginForm").reset();
            } else {
                errorDiv.textContent = "Invalid credentials";
                errorDiv.style.display = "block";
            }
        } catch (error) {
            errorDiv.textContent = "Login failed. Check if server is running.";
            errorDiv.style.display = "block";
        }
    });
}

function setupInitAdminForm() {
    document.getElementById("initAdminForm").addEventListener("submit", async (e) => {
        e.preventDefault();
        const name = document.getElementById("initName").value;
        const username = document.getElementById("initUsername").value;
        const password = document.getElementById("initPassword").value;

        try {
            const response = await fetch(`${API_BASE_URL}/admin/init-admin`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ name, username, password })
            });

            if (response.ok) {
                alert("Admin account created! Now log in with your credentials.");
                document.getElementById("initAdminForm").reset();
                document.getElementById("initAdminDiv").style.display = "none";
                document.getElementById("loginForm").style.display = "block";
            } else {
                alert("Failed to create admin account");
            }
        } catch (error) {
            alert("Error: " + error.message);
        }
    });
}

function showLoginScreen() {
    document.getElementById("loginScreen").classList.add("active");
    document.getElementById("dashboardScreen").classList.remove("active");
}

function showDashboard() {
    document.getElementById("loginScreen").classList.remove("active");
    document.getElementById("dashboardScreen").classList.add("active");
}

function setupLogout() {
    document.getElementById("logoutBtn").addEventListener("click", () => {
        localStorage.removeItem("adminToken");
        localStorage.removeItem("adminName");
        adminToken = null;
        adminName = null;
        showLoginScreen();
        document.getElementById("loginForm").reset();
    });
}

// ==================== TABS ==================== 

function setupTabs() {
    document.querySelectorAll(".nav-item").forEach(item => {
        item.addEventListener("click", () => {
            const tab = item.dataset.tab;
            
            // Update active nav item
            document.querySelectorAll(".nav-item").forEach(i => i.classList.remove("active"));
            item.classList.add("active");
            
            // Update active tab content
            document.querySelectorAll(".tab-content").forEach(t => t.classList.remove("active"));
            document.getElementById(tab + "Tab").classList.add("active");
        });
    });
}

// ==================== FORM HANDLERS ==================== 

function setupFormHandlers() {
    // Attendance Form
    document.getElementById("attendanceForm").addEventListener("submit", addAttendance);
    document.getElementById("removeAttendanceForm").addEventListener("submit", removeAttendance);
    
    // Marks Form
    document.getElementById("marksForm").addEventListener("submit", addMark);
    
    // Notices Form
    document.getElementById("noticesForm").addEventListener("submit", uploadNotice);
    
    // Events Form
    document.getElementById("eventsForm").addEventListener("submit", createEvent);
}

// ==================== ATTENDANCE ==================== 

async function addAttendance(e) {
    e.preventDefault();
    const date = new Date(document.getElementById("attendanceDate").value);
    const formattedDate = (date.getMonth() + 1).toString().padStart(2, '0') + '/' + 
                         date.getDate().toString().padStart(2, '0') + '/' + 
                         date.getFullYear();
    
    const data = {
        date: formattedDate,
        period: parseInt(document.getElementById("period").value),
        subject_code: document.getElementById("subjectCode").value,
        class_code: document.getElementById("classCode").value
    };

    try {
        const response = await fetch(`${API_BASE_URL}/admin/attendance/add`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${adminToken}`
            },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            alert("Absence added successfully!");
            document.getElementById("attendanceForm").reset();
        } else {
            alert("Failed to add absence");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

async function removeAttendance(e) {
    e.preventDefault();
    const date = new Date(document.getElementById("removeDate").value);
    const formattedDate = (date.getMonth() + 1).toString().padStart(2, '0') + '/' + 
                         date.getDate().toString().padStart(2, '0') + '/' + 
                         date.getFullYear();
    
    const data = {
        date: formattedDate,
        period: parseInt(document.getElementById("removePeriod").value),
        class_code: document.getElementById("removeClassCode").value
    };

    try {
        const response = await fetch(`${API_BASE_URL}/admin/attendance/remove`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${adminToken}`
            },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            alert("Absence removed successfully!");
            document.getElementById("removeAttendanceForm").reset();
        } else {
            alert("Failed to remove absence");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

async function viewAbsences() {
    const classCode = document.getElementById("viewClassCode").value;
    if (!classCode) {
        alert("Please enter class code");
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/admin/attendance/${classCode}`, {
            headers: {
                "Authorization": `Bearer ${adminToken}`
            }
        });

        if (response.ok) {
            const absences = await response.json();
            displayAbsencesTable(absences);
        } else {
            alert("Failed to load absences");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

function displayAbsencesTable(absences) {
    let html = '<div class="table-container"><table><thead><tr><th>Date</th><th>Period</th><th>Subject Code</th></tr></thead><tbody>';
    
    for (const [date, records] of Object.entries(absences)) {
        records.forEach((record, index) => {
            html += `<tr><td>${date}</td><td>${record.period}</td><td>${record.subject_code}</td></tr>`;
        });
    }
    
    html += '</tbody></table></div>';
    document.getElementById("absencesTable").innerHTML = html;
}

// ==================== MARKS ==================== 

async function addMark(e) {
    e.preventDefault();
    const data = {
        class_code: document.getElementById("marksClassCode").value,
        subject_code: document.getElementById("marksSubjectCode").value,
        student_id: document.getElementById("studentId").value,
        mark: document.getElementById("markValue").value
    };

    try {
        const response = await fetch(`${API_BASE_URL}/admin/marks/add`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${adminToken}`
            },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            alert("Mark saved successfully!");
            document.getElementById("marksForm").reset();
        } else {
            alert("Failed to save mark");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

async function viewMarks() {
    const studentId = document.getElementById("viewStudentId").value;
    const classCode = document.getElementById("viewMarksClassCode").value;
    
    if (!studentId || !classCode) {
        alert("Please enter both Student ID and Class Code");
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/admin/marks/${studentId}/${classCode}`, {
            headers: {
                "Authorization": `Bearer ${adminToken}`
            }
        });

        if (response.ok) {
            const data = await response.json();
            displayMarksTable(data.marks);
        } else {
            alert("Failed to load marks");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

function displayMarksTable(marks) {
    let html = '<div class="table-container"><table><thead><tr><th>Subject Code</th><th>Mark</th></tr></thead><tbody>';
    
    marks.forEach(mark => {
        html += `<tr><td>${mark.subject_code}</td><td>${mark.mark}</td></tr>`;
    });
    
    html += '</tbody></table></div>';
    document.getElementById("marksTable").innerHTML = html;
}

// ==================== NOTICES ==================== 

async function uploadNotice(e) {
    e.preventDefault();
    
    const formData = new FormData();
    formData.append("title", document.getElementById("noticeTitle").value);
    formData.append("is_exam_notice", document.getElementById("noticeType").value);
    formData.append("file", document.getElementById("pdfFile").files[0]);

    try {
        const response = await fetch(`${API_BASE_URL}/admin/notices/upload`, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${adminToken}`
            },
            body: formData
        });

        if (response.ok) {
            alert("Notice uploaded successfully!");
            document.getElementById("noticesForm").reset();
            loadNotices('all');
        } else {
            const error = await response.json();
            alert("Failed to upload: " + error.detail);
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

async function loadNotices(type) {
    try {
        const isExam = type === 'exam' ? true : false;
        const response = await fetch(`${API_BASE_URL}/admin/notices?is_exam=${isExam}`, {
            headers: {
                "Authorization": `Bearer ${adminToken}`
            }
        });

        if (response.ok) {
            const notices = await response.json();
            displayNoticesTable(notices);
        } else {
            alert("Failed to load notices");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

function displayNoticesTable(notices) {
    let html = '<div class="table-container"><table><thead><tr><th>Title</th><th>Type</th><th>Upload Date</th><th>Action</th></tr></thead><tbody>';
    
    notices.forEach(notice => {
        const type = notice.is_exam_notice ? 'Exam' : 'Regular';
        const date = new Date(notice.upload_date).toLocaleDateString();
        html += `<tr>
            <td>${notice.title}</td>
            <td>${type}</td>
            <td>${date}</td>
            <td>
                <button class="btn-delete" onclick="deleteNotice('${notice.id}')">Delete</button>
            </td>
        </tr>`;
    });
    
    html += '</tbody></table></div>';
    document.getElementById("noticesTable").innerHTML = html;
}

async function deleteNotice(noticeId) {
    if (!confirm("Are you sure you want to delete this notice?")) return;

    try {
        const response = await fetch(`${API_BASE_URL}/admin/notices/${noticeId}`, {
            method: "DELETE",
            headers: {
                "Authorization": `Bearer ${adminToken}`
            }
        });

        if (response.ok) {
            alert("Notice deleted!");
            loadNotices('all');
        } else {
            alert("Failed to delete notice");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

// ==================== EVENTS ==================== 

async function createEvent(e) {
    e.preventDefault();
    
    const date = new Date(document.getElementById("eventDate").value);
    const formattedDate = (date.getMonth() + 1).toString().padStart(2, '0') + '/' + 
                         date.getDate().toString().padStart(2, '0') + '/' + 
                         date.getFullYear();
    
    const data = {
        title: document.getElementById("eventTitle").value,
        date: formattedDate,
        description: document.getElementById("eventDescription").value
    };

    try {
        const response = await fetch(`${API_BASE_URL}/admin/events/create`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${adminToken}`
            },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            alert("Event created successfully!");
            document.getElementById("eventsForm").reset();
            loadEvents();
        } else {
            alert("Failed to create event");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

async function loadEvents() {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/events`, {
            headers: {
                "Authorization": `Bearer ${adminToken}`
            }
        });

        if (response.ok) {
            const events = await response.json();
            displayEventsTable(events);
        } else {
            alert("Failed to load events");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}

function displayEventsTable(events) {
    let html = '<div class="table-container"><table><thead><tr><th>Title</th><th>Date</th><th>Description</th><th>Action</th></tr></thead><tbody>';
    
    events.forEach(event => {
        const desc = event.description || '-';
        html += `<tr>
            <td>${event.title}</td>
            <td>${event.date}</td>
            <td>${desc}</td>
            <td>
                <button class="btn-delete" onclick="deleteEvent('${event.id}')">Delete</button>
            </td>
        </tr>`;
    });
    
    html += '</tbody></table></div>';
    document.getElementById("eventsTable").innerHTML = html;
}

async function deleteEvent(eventId) {
    if (!confirm("Are you sure you want to delete this event?")) return;

    try {
        const response = await fetch(`${API_BASE_URL}/admin/events/${eventId}`, {
            method: "DELETE",
            headers: {
                "Authorization": `Bearer ${adminToken}`
            }
        });

        if (response.ok) {
            alert("Event deleted!");
            loadEvents();
        } else {
            alert("Failed to delete event");
        }
    } catch (error) {
        alert("Error: " + error.message);
    }
}
