package com.policysquare.commercial.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;

@Entity
@Table(name = "health_premium_matrix")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HealthPremiumMatrix {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private HealthProduct product;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "sum_insured_id", nullable = false)
    private HealthSumInsured sumInsured;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "age_band_id", nullable = false)
    private HealthAgeBand ageBand;

    @Column(name = "city_tier", length = 50, nullable = false)
    private String cityTier;

    @Column(length = 50)
    private String members; // e.g. 1A, 2A, 2A1C

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal premium;
}
