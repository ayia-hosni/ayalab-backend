package com.ayalab.repository;

import com.ayalab.entity.LessonSection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LessonSectionRepository extends JpaRepository<LessonSection, Long> {

    List<LessonSection> findAllByOrderByOrdinal();

    boolean existsBySlug(String slug);
}
