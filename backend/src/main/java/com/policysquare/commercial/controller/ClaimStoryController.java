package com.policysquare.commercial.controller;

import com.policysquare.commercial.model.ClaimStory;
import com.policysquare.commercial.service.ClaimStoryService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/claims/stories")
@CrossOrigin(originPatterns = "*")
@RequiredArgsConstructor
public class ClaimStoryController {

    private final ClaimStoryService service;
    private final ObjectMapper objectMapper;

    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<?> createStory(
            @RequestParam("storyData") String storyData,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        try {
            ClaimStory story = objectMapper.readValue(storyData, ClaimStory.class);
            return ResponseEntity.ok(service.createStory(story, image));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error creating story: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<?> getAllStories(@RequestParam(required = false) String category) {
        if (category != null && !category.isEmpty()) {
            return ResponseEntity.ok(service.getStoriesByCategory(category));
        }
        return ResponseEntity.ok(service.getAllStories());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getStoryById(@PathVariable String id) {
        return ResponseEntity.ok(service.getStoryById(id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteStory(@PathVariable String id) {
        service.deleteStory(id);
        return ResponseEntity.ok().build();
    }
}
