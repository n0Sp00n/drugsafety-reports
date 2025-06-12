package com.drugsafety.reports.controller;

import com.drugsafety.reports.dto.CreateReportRequest;
import com.drugsafety.reports.model.SafetyReport;
import com.drugsafety.reports.service.SafetyReportService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import java.util.Optional;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(SafetyReportController.class)
class SafetyReportControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private SafetyReportService service;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser
    void createReport_ShouldReturn201() throws Exception {
        CreateReportRequest request = new CreateReportRequest("John Doe", "Aspirin", "Side effect");
        SafetyReport report = new SafetyReport("John Doe", "Aspirin", "Side effect");

        when(service.createReport(any(CreateReportRequest.class))).thenReturn(report);

        mockMvc.perform(post("/api/reports")
                        .with(csrf()) // Add CSRF token for POST requests
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.reporterName").value("John Doe"))
                .andExpect(jsonPath("$.productName").value("Aspirin"));
    }

    @Test
    @WithMockUser
    void getReport_WhenExists_ShouldReturn200() throws Exception {
        String reportId = "test-id";
        SafetyReport report = new SafetyReport("John Doe", "Aspirin", "Side effect");

        when(service.getReportById(reportId)).thenReturn(Optional.of(report));

        mockMvc.perform(get("/api/reports/{id}", reportId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reporterName").value("John Doe"));
    }

    @Test
    @WithMockUser
    void getReport_WhenNotExists_ShouldReturn404() throws Exception {
        String reportId = "non-existent";

        when(service.getReportById(reportId)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/reports/{id}", reportId))
                .andExpect(status().isNotFound());
    }
}