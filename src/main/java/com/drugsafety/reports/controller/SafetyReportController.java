package com.drugsafety.reports.controller;

import com.drugsafety.reports.dto.CreateReportRequest;
import com.drugsafety.reports.model.SafetyReport;
import com.drugsafety.reports.model.ReportStatus;
import com.drugsafety.reports.service.SafetyReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/reports")
@Tag(name = "Safety Reports", description = "Drug Safety Reporting API")
@SecurityRequirement(name = "basicAuth")
public class SafetyReportController {

    @Autowired
    private SafetyReportService safetyReportService;

    @PostMapping
    @Operation(summary = "Submit a new safety report")
    @ApiResponse(responseCode = "201", description = "Report created successfully")
    @ApiResponse(responseCode = "400", description = "Invalid input data")
    public ResponseEntity<SafetyReport> createReport(@Valid @RequestBody CreateReportRequest request) {
        SafetyReport report = safetyReportService.createReport(request);
        return new ResponseEntity<>(report, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a safety report by ID")
    @ApiResponse(responseCode = "200", description = "Report found")
    @ApiResponse(responseCode = "404", description = "Report not found")
    public ResponseEntity<SafetyReport> getReport(
            @Parameter(description = "Report ID") @PathVariable String id) {
        Optional<SafetyReport> report = safetyReportService.getReportById(id);
        return report.map(r -> ResponseEntity.ok(r))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    @Operation(summary = "List all safety reports with optional filtering")
    @ApiResponse(responseCode = "200", description = "Reports retrieved successfully")
    public ResponseEntity<List<SafetyReport>> getAllReports(
            @Parameter(description = "Filter by status") @RequestParam(required = false) ReportStatus status,
            @Parameter(description = "Filter by product name") @RequestParam(required = false) String productName) {
        List<SafetyReport> reports = safetyReportService.getAllReports(status, productName);
        return ResponseEntity.ok(reports);
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "Update report status")
    @ApiResponse(responseCode = "200", description = "Status updated successfully")
    @ApiResponse(responseCode = "404", description = "Report not found")
    public ResponseEntity<SafetyReport> updateStatus(
            @Parameter(description = "Report ID") @PathVariable String id,
            @Parameter(description = "New status") @RequestParam ReportStatus status) {
        Optional<SafetyReport> report = safetyReportService.updateReportStatus(id, status);
        return report.map(r -> ResponseEntity.ok(r))
                .orElse(ResponseEntity.notFound().build());
    }
}