package com.policysquare.commercial.controller;

import com.policysquare.commercial.model.UnderwritingTip;
import com.policysquare.commercial.service.UnderwritingTipService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/underwriting/tips")
@CrossOrigin(originPatterns = "*")
@RequiredArgsConstructor
public class UnderwritingTipController {

    private final UnderwritingTipService service;
    private final ObjectMapper objectMapper;

    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<?> createTip(
            @RequestParam("tipData") String tipData,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        try {
            UnderwritingTip tip = objectMapper.readValue(tipData, UnderwritingTip.class);
            return ResponseEntity.ok(service.createTip(tip, image));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error creating tip: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<?> getAllTips(@RequestParam(required = false) String category) {
        if (category != null && !category.isEmpty()) {
            return ResponseEntity.ok(service.getTipsByCategory(category));
        }
        return ResponseEntity.ok(service.getAllTips());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getTipById(@PathVariable String id) {
        return ResponseEntity.ok(service.getTipById(id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTip(@PathVariable String id) {
        service.deleteTip(id);
        return ResponseEntity.ok().build();
    }
}
