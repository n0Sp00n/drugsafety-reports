package com.drugsafety.reports.repository;

import com.drugsafety.reports.model.SafetyReport;
import com.drugsafety.reports.model.ReportStatus;
import org.springframework.stereotype.Repository;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Repository
public class SafetyReportRepository {
    private final Map<String, SafetyReport> reports = new ConcurrentHashMap<>();

    public SafetyReport save(SafetyReport report) {
        reports.put(report.getId(), report);
        return report;
    }

    public Optional<SafetyReport> findById(String id) {
        return Optional.ofNullable(reports.get(id));
    }

    public List<SafetyReport> findAll() {
        return new ArrayList<>(reports.values());
    }

    public List<SafetyReport> findByStatus(ReportStatus status) {
        return reports.values().stream()
                .filter(report -> report.getStatus() == status)
                .collect(Collectors.toList());
    }

    public List<SafetyReport> findByProductName(String productName) {
        return reports.values().stream()
                .filter(report -> report.getProductName().toLowerCase()
                        .contains(productName.toLowerCase()))
                .collect(Collectors.toList());
    }
}