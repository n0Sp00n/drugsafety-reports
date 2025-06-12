package com.drugsafety.reports.service;

import com.drugsafety.reports.dto.CreateReportRequest;
import com.drugsafety.reports.model.SafetyReport;
import com.drugsafety.reports.model.ReportStatus;
import com.drugsafety.reports.repository.SafetyReportRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SafetyReportServiceTest {

    @Mock
    private SafetyReportRepository repository;

    @InjectMocks
    private SafetyReportService service;

    private CreateReportRequest request;
    private SafetyReport report;

    @BeforeEach
    void setUp() {
        request = new CreateReportRequest("John Doe", "Aspirin", "Headache worsened");
        report = new SafetyReport("John Doe", "Aspirin", "Headache worsened");
    }

    @Test
    void createReport_ShouldReturnSavedReport() {
        when(repository.save(any(SafetyReport.class))).thenReturn(report);

        SafetyReport result = service.createReport(request);

        assertNotNull(result);
        assertEquals("John Doe", result.getReporterName());
        assertEquals("Aspirin", result.getProductName());
        assertEquals(ReportStatus.NEW, result.getStatus());
        verify(repository).save(any(SafetyReport.class));
    }

    @Test
    void getReportById_WhenExists_ShouldReturnReport() {
        String reportId = "test-id";
        when(repository.findById(reportId)).thenReturn(Optional.of(report));

        Optional<SafetyReport> result = service.getReportById(reportId);

        assertTrue(result.isPresent());
        assertEquals(report, result.get());
    }

    @Test
    void updateReportStatus_WhenExists_ShouldUpdateAndReturn() {
        String reportId = "test-id";
        when(repository.findById(reportId)).thenReturn(Optional.of(report));
        when(repository.save(any(SafetyReport.class))).thenReturn(report);

        Optional<SafetyReport> result = service.updateReportStatus(reportId, ReportStatus.IN_REVIEW);

        assertTrue(result.isPresent());
        assertEquals(ReportStatus.IN_REVIEW, result.get().getStatus());
        verify(repository).save(report);
    }
}
