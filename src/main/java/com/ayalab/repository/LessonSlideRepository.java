package com.ayalab.repository;

import com.ayalab.entity.LessonSlide;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface LessonSlideRepository extends JpaRepository<LessonSlide, Long> {

    List<LessonSlide> findByLessonIdOrderByOrdinal(Long lessonId);

    List<LessonSlide> findByLessonIdInOrderByLessonIdAscOrdinalAsc(Collection<Long> lessonIds);

    /** One row per lesson: {lessonId, slideCount}. Replaces a count query per lesson. */
    @Query("select s.lessonId, count(s) from LessonSlide s group by s.lessonId")
    List<Object[]> countGroupedByLesson();

    void deleteByLessonId(Long lessonId);
}
