package com.policysquare.commercial.service;

import com.policysquare.commercial.model.RiskAssessment;
import com.policysquare.commercial.repository.RiskAssessmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RiskAssessmentService {

    private final RiskAssessmentRepository repository;

    public synchronized RiskAssessment createAssessment(RiskAssessment assessment) {
        if (assessment.getStatus() == null) {
            assessment.setStatus(RiskAssessment.AssessmentStatus.STARTED);
        }
        if (assessment.getId() == null || assessment.getId().isEmpty()) {
            long count = repository.count();
            assessment.setId(String.format("SIBPL%02d", count + 1));
        }
        return repository.save(assessment);
    }

    public List<RiskAssessment> getAllAssessments() {
        return repository.findAll();
    }

    public List<RiskAssessment> getAssessmentsByMobileNumber(String mobileNumber) {
        System.out.println("Fetching assessments for mobile: " + mobileNumber);
        List<RiskAssessment> assessments = repository.findByMobileNumberOrderByCreatedAtDesc(mobileNumber);
        System.out.println("Found " + assessments.size() + " assessments.");
        return assessments;
    }

    public RiskAssessment getAssessmentById(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Assessment not found with id " + id));
    }

    public RiskAssessment updateAssessment(String id, RiskAssessment updatedAssessment) {
        System.out.println("Updating Assessment ID: " + id);
        System.out.println("Payload Data: " + updatedAssessment.getData());
        System.out.println("Payload Status: " + updatedAssessment.getStatus());

        return repository.findById(id)
                .map(existing -> {
                    if (updatedAssessment.getData() != null) {
                        existing.setData(updatedAssessment.getData()); 
                    }
                    if (updatedAssessment.getStatus() != null) {
                        existing.setStatus(updatedAssessment.getStatus());
                    }
                    return repository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("Assessment not found with id " + id));
    }
}
