package com.ayalab.repository;

import com.ayalab.entity.ProblemTestCase;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProblemTestCaseRepository extends JpaRepository<ProblemTestCase, Long> {

    List<ProblemTestCase> findByProblemIdOrderByOrdinal(Long problemId);
}