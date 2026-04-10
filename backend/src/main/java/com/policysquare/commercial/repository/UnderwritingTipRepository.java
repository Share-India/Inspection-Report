package com.policysquare.commercial.repository;

import com.policysquare.commercial.model.UnderwritingTip;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UnderwritingTipRepository extends JpaRepository<UnderwritingTip, String> {
    List<UnderwritingTip> findAllByOrderByCreatedAtDesc();
    List<UnderwritingTip> findByCategoryOrderByCreatedAtDesc(String category);
}
