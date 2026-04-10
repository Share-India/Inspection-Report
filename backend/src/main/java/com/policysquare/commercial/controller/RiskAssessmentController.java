package com.policysquare.commercial.controller;

import com.policysquare.commercial.model.RiskAssessment;
import com.policysquare.commercial.service.RiskAssessmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/risk-assessments")
@CrossOrigin(originPatterns = "*")
@RequiredArgsConstructor
public class RiskAssessmentController {

    private final RiskAssessmentService service;

    @PostMapping
    public ResponseEntity<?> createAssessment(@RequestBody RiskAssessment assessment) {
        try {
            return ResponseEntity.ok(service.createAssessment(assessment));
        } catch (Exception e) {
            e.printStackTrace(); // Log to console for user to see
            return ResponseEntity.internalServerError().body("Error creating assessment: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<List<RiskAssessment>> getAllAssessments() {
        return ResponseEntity.ok(service.getAllAssessments());
    }

    @GetMapping("/user/{mobileNumber}")
    public ResponseEntity<List<RiskAssessment>> getUserAssessments(@PathVariable String mobileNumber) {
        return ResponseEntity.ok(service.getAssessmentsByMobileNumber(mobileNumber));
    }

    @GetMapping("/{id}")
    public ResponseEntity<RiskAssessment> getAssessmentById(@PathVariable String id) {
        System.out.println("GET Request for Assessment ID: " + id);
        return ResponseEntity.ok(service.getAssessmentById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<RiskAssessment> updateAssessment(@PathVariable String id, @RequestBody RiskAssessment assessment) {
        return ResponseEntity.ok(service.updateAssessment(id, assessment));
    }
}
