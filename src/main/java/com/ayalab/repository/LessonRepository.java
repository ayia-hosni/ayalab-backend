package com.ayalab.repository;

import com.ayalab.entity.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LessonRepository extends JpaRepository<Lesson, Long> {

    /** Section and category are fetched in the same query; translations load lazily in batches. */
    @Query("select l from Lesson l join fetch l.section left join fetch l.category order by l.ordinal")
    List<Lesson> findAllWithTaxonomy();

    @Query("select l from Lesson l join fetch l.section left join fetch l.category "
            + "where l.published = true order by l.ordinal")
    List<Lesson> findPublishedWithTaxonomy();

    @Query("select l from Lesson l join fetch l.section left join fetch l.category where l.id = :id")
    Optional<Lesson> findByIdWithTaxonomy(Long id);

    @Query("select l from Lesson l join fetch l.section left join fetch l.category where l.slug = :slug")
    Optional<Lesson> findBySlugWithTaxonomy(String slug);

    boolean existsBySlug(String slug);

    boolean existsBySlugAndIdNot(String slug, Long id);
}
