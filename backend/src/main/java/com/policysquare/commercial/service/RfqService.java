package com.policysquare.commercial.service;

import com.policysquare.commercial.model.Rfq;
import com.policysquare.commercial.repository.RfqRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RfqService {

    private final RfqRepository repository;

    public Rfq submitRfq(Rfq rfq) {
        return repository.save(rfq);
    }

    public List<Rfq> getAllRfqs() {
        return repository.findAllByOrderByCreatedAtDesc();
    }

    public List<Rfq> getUserRfqs(String mobileNumber) {
        return repository.findByMobileNumberOrderByCreatedAtDesc(mobileNumber);
    }

    public Rfq getRfqById(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("RFQ not found with id " + id));
    }

    public Rfq updateQuote(String id, String quoteDetails, String status, org.springframework.web.multipart.MultipartFile file) {
        return repository.findById(id)
                .map(rfq -> {
                    rfq.setQuoteDetails(quoteDetails);
                    if (status != null) {
                        try {
                            rfq.setStatus(Rfq.RfqStatus.valueOf(status));
                        } catch (IllegalArgumentException e) {
                            // ignore invalid status
                        }
                    }
                    if (file != null && !file.isEmpty()) {
                        try {
                            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
                            java.nio.file.Path uploadPath = java.nio.file.Paths.get("uploads");
                            if (!java.nio.file.Files.exists(uploadPath)) {
                                java.nio.file.Files.createDirectories(uploadPath);
                            }
                            java.nio.file.Files.copy(file.getInputStream(), uploadPath.resolve(fileName), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                            rfq.setQuoteFilePath("/uploads/" + fileName);
                        } catch (java.io.IOException e) {
                            throw new RuntimeException("Failed to store file " + e.getMessage());
                        }
                    }
                    return repository.save(rfq);
                })
                .orElseThrow(() -> new RuntimeException("RFQ not found with id " + id));
    }
}
