package com.policysquare.commercial.service;

import com.policysquare.commercial.model.ClaimStory;
import com.policysquare.commercial.repository.ClaimStoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ClaimStoryService {

    private final ClaimStoryRepository repository;
    private final Path uploadPath = Paths.get("uploads");

    public ClaimStory createStory(ClaimStory story, MultipartFile image) throws IOException {
        if (image != null && !image.isEmpty()) {
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            String fileName = System.currentTimeMillis() + "_" + image.getOriginalFilename();
            Files.copy(image.getInputStream(), uploadPath.resolve(fileName));
            story.setImagePath("/uploads/" + fileName);
        }
        return repository.save(story);
    }

    public List<ClaimStory> getAllStories() {
        return repository.findAllByOrderByCreatedAtDesc();
    }
    
    public List<ClaimStory> getStoriesByCategory(String category) {
        return repository.findByCategoryOrderByCreatedAtDesc(category);
    }
    
    public ClaimStory getStoryById(String id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Story not found"));
    }

    public void deleteStory(String id) {
        repository.deleteById(id);
    }
}
