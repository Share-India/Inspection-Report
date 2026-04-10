package com.policysquare.commercial.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "rfqs")
public class Rfq {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(name = "mobile_number")
    private String mobileNumber;

    @Column(name = "company_name")
    private String companyName;

    private String product;

    @Enumerated(EnumType.STRING)
    private RfqStatus status;

    @Column(columnDefinition = "TEXT")
    private String rfqData; // JSON of the form

    @Column(columnDefinition = "TEXT")
    private String quoteDetails; // Admin response (text or JSON)
    
    @Column(name = "quote_file_path")
    private String quoteFilePath;

    @Column(updatable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;

    public enum RfqStatus {
        PENDING, QUOTED
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (status == null) {
            status = RfqStatus.PENDING;
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
