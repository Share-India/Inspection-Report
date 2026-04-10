package com.policysquare.commercial.repository;

import com.policysquare.commercial.model.HealthPremiumMatrix;
import com.policysquare.commercial.model.HealthAgeBand;
import com.policysquare.commercial.model.HealthSumInsured;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HealthPremiumMatrixRepository extends JpaRepository<HealthPremiumMatrix, Long> {
    List<HealthPremiumMatrix> findBySumInsuredAndAgeBandAndCityTierAndMembersIgnoreCase(
            HealthSumInsured sumInsured, 
            HealthAgeBand ageBand, 
            String cityTier,
            String members);
}
