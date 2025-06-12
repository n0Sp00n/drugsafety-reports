package com.drugsafety.reports.dto;

import jakarta.validation.constraints.NotBlank;

public class CreateReportRequest {
    @NotBlank(message = "Reporter name is required")
    private String reporterName;

    @NotBlank(message = "Product name is required")
    private String productName;

    @NotBlank(message = "Issue description is required")
    private String issueDescription;

    // Constructors
    public CreateReportRequest() {}

    public CreateReportRequest(String reporterName, String productName, String issueDescription) {
        this.reporterName = reporterName;
        this.productName = productName;
        this.issueDescription = issueDescription;
    }

    // Getters and Setters
    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getIssueDescription() { return issueDescription; }
    public void setIssueDescription(String issueDescription) { this.issueDescription = issueDescription; }
}