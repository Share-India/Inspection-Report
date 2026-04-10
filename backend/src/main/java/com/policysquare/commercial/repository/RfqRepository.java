package com.policysquare.commercial.repository;

import com.policysquare.commercial.model.Rfq;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RfqRepository extends JpaRepository<Rfq, String> {
    List<Rfq> findByMobileNumberOrderByCreatedAtDesc(String mobileNumber);
    List<Rfq> findAllByOrderByCreatedAtDesc();
}
