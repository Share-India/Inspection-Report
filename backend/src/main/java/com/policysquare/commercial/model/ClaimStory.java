package com.policysquare.commercial.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@Table(name = "claim_stories")
public class ClaimStory {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String title;
    
    private String category; // e.g. Commercial, Health, Life, Motor
    
    @Column(name = "case_name")
    private String caseName;
    
    private String court;
    
    @Column(columnDefinition = "TEXT")
    private String issue;

    @Column(columnDefinition = "TEXT")
    private String story; // The Claim Story

    @Column(columnDefinition = "TEXT")
    private String verdict;

    @ElementCollection
    private List<String> principles; // Critical Legal Principles

    @Column(columnDefinition = "TEXT")
    private String bottomLine;

    private String imagePath; // Path to uploaded image

    @Column(updatable = false)
    @com.fasterxml.jackson.annotation.JsonFormat(shape = com.fasterxml.jackson.annotation.JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
