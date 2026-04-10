package com.policysquare.commercial.repository;

import com.policysquare.commercial.model.ClaimStory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClaimStoryRepository extends JpaRepository<ClaimStory, String> {
    List<ClaimStory> findAllByOrderByCreatedAtDesc();
    List<ClaimStory> findByCategoryOrderByCreatedAtDesc(String category);
}
