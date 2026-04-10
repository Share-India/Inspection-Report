package com.policysquare.commercial.service;

import com.policysquare.commercial.dto.HealthQuoteRequest;
import com.policysquare.commercial.dto.HealthQuoteResponse;
import com.policysquare.commercial.model.HealthAgeBand;
import com.policysquare.commercial.model.HealthPremiumMatrix;
import com.policysquare.commercial.model.HealthSumInsured;
import com.policysquare.commercial.repository.HealthAgeBandRepository;
import com.policysquare.commercial.repository.HealthPremiumMatrixRepository;
import com.policysquare.commercial.repository.HealthSumInsuredRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class HealthQuoteService {

    @Autowired
    private HealthAgeBandRepository ageBandRepository;

    @Autowired
    private HealthSumInsuredRepository sumInsuredRepository;

    @Autowired
    private HealthPremiumMatrixRepository premiumMatrixRepository;

    public List<HealthQuoteResponse> calculateQuotes(HealthQuoteRequest request) {
        HealthAgeBand ageBand = ageBandRepository.findBandForAge(request.getAge())
                .orElseThrow(() -> new IllegalArgumentException("No age band found for age: " + request.getAge()));

        HealthSumInsured sumInsured = sumInsuredRepository.findByAmount(request.getSelectedSumInsured())
                .orElseThrow(() -> new IllegalArgumentException("Invalid sum insured dimension: " + request.getSelectedSumInsured()));

        List<HealthPremiumMatrix> matrices = premiumMatrixRepository
                .findBySumInsuredAndAgeBandAndCityTierAndMembersIgnoreCase(
                        sumInsured, ageBand, request.getCityTier(), request.getMembers());

        return matrices.stream().map(matrix -> new HealthQuoteResponse(
                matrix.getProduct().getCompany().getName(),
                matrix.getProduct().getCompany().getLogoUrl(),
                matrix.getProduct().getName(),
                matrix.getProduct().getType(),
                matrix.getSumInsured().getAmount(),
                matrix.getPremium()
        )).collect(Collectors.toList());
    }
}
