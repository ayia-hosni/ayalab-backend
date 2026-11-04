package com.ayalab.repository;

import com.ayalab.entity.LessonCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LessonCategoryRepository extends JpaRepository<LessonCategory, Long> {

    List<LessonCategory> findAllByOrderBySectionIdAscOrdinalAsc();

    boolean existsBySectionIdAndSlug(Long sectionId, String slug);
}
