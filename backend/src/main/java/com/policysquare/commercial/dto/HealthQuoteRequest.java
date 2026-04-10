package com.policysquare.commercial.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class HealthQuoteRequest {
    private Integer age;
    private String cityTier; // e.g. Tier 1, Tier 2, Tier 3
    private String members; // e.g. 1A, 2A, 2A1C
    private BigDecimal selectedSumInsured;
}
