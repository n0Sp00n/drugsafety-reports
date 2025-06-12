package com.drugsafety.reports.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.UUID;

public class SafetyReport {
    private String id;

    @NotBlank(message = "Reporter name is required")
    private String reporterName;

    @NotBlank(message = "Product name is required")
    private String productName;

    @NotBlank(message = "Issue description is required")
    private String issueDescription;

    private LocalDateTime timestamp;

    @NotNull(message = "Status is required")
    private ReportStatus status;

    public SafetyReport() {
        this.id = UUID.randomUUID().toString();
        this.timestamp = LocalDateTime.now();
        this.status = ReportStatus.NEW;
    }

    public SafetyReport(String reporterName, String productName, String issueDescription) {
        this();
        this.reporterName = reporterName;
        this.productName = productName;
        this.issueDescription = issueDescription;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getIssueDescription() { return issueDescription; }
    public void setIssueDescription(String issueDescription) { this.issueDescription = issueDescription; }

    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }

    public ReportStatus getStatus() { return status; }
    public void setStatus(ReportStatus status) { this.status = status; }
}
