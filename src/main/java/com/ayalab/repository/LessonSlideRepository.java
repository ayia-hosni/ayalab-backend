package com.ayalab.repository;

import com.ayalab.entity.LessonSlide;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LessonSlideRepository extends JpaRepository<LessonSlide, Long> {

    List<LessonSlide> findByLessonIdOrderByOrdinal(Long lessonId);

    long countByLessonId(Long lessonId);
}
