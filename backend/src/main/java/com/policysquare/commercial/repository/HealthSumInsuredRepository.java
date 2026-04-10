package com.policysquare.commercial.repository;

import com.policysquare.commercial.model.HealthSumInsured;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Optional;

@Repository
public interface HealthSumInsuredRepository extends JpaRepository<HealthSumInsured, Long> {
    Optional<HealthSumInsured> findByAmount(BigDecimal amount);
}
