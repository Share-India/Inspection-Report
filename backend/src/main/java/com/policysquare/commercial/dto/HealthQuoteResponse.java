package com.policysquare.commercial.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class HealthQuoteResponse {
    private String companyName;
    private String companyLogoUrl;
    private String productName;
    private String type;
    private BigDecimal sumInsured;
    private BigDecimal premium;
}
