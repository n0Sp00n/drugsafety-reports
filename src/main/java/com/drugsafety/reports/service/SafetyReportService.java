package com.drugsafety.reports.service;

import com.drugsafety.reports.dto.CreateReportRequest;
import com.drugsafety.reports.model.SafetyReport;
import com.drugsafety.reports.model.ReportStatus;
import com.drugsafety.reports.repository.SafetyReportRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class SafetyReportService {

    @Autowired
    private SafetyReportRepository repository;

    public SafetyReport createReport(CreateReportRequest request) {
        SafetyReport report = new SafetyReport(
                request.getReporterName(),
                request.getProductName(),
                request.getIssueDescription()
        );
        return repository.save(report);
    }

    public Optional<SafetyReport> getReportById(String id) {
        return repository.findById(id);
    }

    public List<SafetyReport> getAllReports(ReportStatus status, String productName) {
        if (status != null) {
            return repository.findByStatus(status);
        }
        if (productName != null && !productName.trim().isEmpty()) {
            return repository.findByProductName(productName);
        }
        return repository.findAll();
    }

    public Optional<SafetyReport> updateReportStatus(String id, ReportStatus status) {
        Optional<SafetyReport> reportOpt = repository.findById(id);
        if (reportOpt.isPresent()) {
            SafetyReport report = reportOpt.get();
            report.setStatus(status);
            repository.save(report);
            return Optional.of(report);
        }
        return Optional.empty();
    }
}
