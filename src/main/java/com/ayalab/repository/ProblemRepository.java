package com.ayalab.repository;

import com.ayalab.entity.Difficulty;
import com.ayalab.entity.Problem;
import com.ayalab.entity.ProblemStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProblemRepository extends JpaRepository<Problem, Long> {

    Optional<Problem> findBySlug(String slug);

    /**
     * Filtered search. Any parameter may be null to skip that filter.
     * Tag matching is case-insensitive and matches problems that contain the tag.
     */
    @Query("""
            select distinct p from Problem p left join p.tags t
            where (:difficulty is null or p.difficulty = :difficulty)
              and (:status is null or p.status = :status)
              and (:search is null or lower(p.title) like concat('%', cast(:search as String), '%')
                                   or cast(p.id as String) like concat('%', cast(:search as String), '%'))
              and (:tag is null or lower(t) = cast(:tag as String))
            order by p.id asc
            """)
    List<Problem> search(@Param("difficulty") Difficulty difficulty,
                         @Param("status") ProblemStatus status,
                         @Param("search") String search,
                         @Param("tag") String tag);
}
