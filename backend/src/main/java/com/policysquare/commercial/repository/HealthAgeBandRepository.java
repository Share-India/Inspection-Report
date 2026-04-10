package com.policysquare.commercial.repository;

import com.policysquare.commercial.model.HealthAgeBand;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface HealthAgeBandRepository extends JpaRepository<HealthAgeBand, Long> {
    @Query("SELECT b FROM HealthAgeBand b WHERE :age >= b.minAge AND :age <= b.maxAge")
    Optional<HealthAgeBand> findBandForAge(@Param("age") Integer age);
}
