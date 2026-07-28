package com.ayalab.repository;

import com.ayalab.entity.ProblemGameConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProblemGameConfigRepository extends JpaRepository<ProblemGameConfig, Long> {

    List<ProblemGameConfig> findByProblemId(Long problemId);
}
