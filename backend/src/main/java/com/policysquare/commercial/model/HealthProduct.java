package com.policysquare.commercial.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "health_product")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HealthProduct {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "company_id", nullable = false)
    private HealthCompany company;

    @Column(nullable = false)
    private String name;

    @Column(length = 50)
    private String type; // e.g. Individual, Floater
}
