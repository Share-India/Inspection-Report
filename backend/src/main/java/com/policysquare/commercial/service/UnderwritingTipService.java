package com.policysquare.commercial.service;

import com.policysquare.commercial.model.UnderwritingTip;
import com.policysquare.commercial.repository.UnderwritingTipRepository;
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
public class UnderwritingTipService {

    private final UnderwritingTipRepository repository;
    private final Path uploadPath = Paths.get("uploads");

    public UnderwritingTip createTip(UnderwritingTip tip, MultipartFile image) throws IOException {
        if (image != null && !image.isEmpty()) {
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            String fileName = System.currentTimeMillis() + "_" + image.getOriginalFilename();
            Files.copy(image.getInputStream(), uploadPath.resolve(fileName));
            tip.setImagePath("/uploads/" + fileName);
        }
        return repository.save(tip);
    }

    public List<UnderwritingTip> getAllTips() {
        return repository.findAllByOrderByCreatedAtDesc();
    }

    public List<UnderwritingTip> getTipsByCategory(String category) {
        return repository.findByCategoryOrderByCreatedAtDesc(category);
    }

    public UnderwritingTip getTipById(String id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Tip not found"));
    }

    public void deleteTip(String id) {
        repository.deleteById(id);
    }
}
