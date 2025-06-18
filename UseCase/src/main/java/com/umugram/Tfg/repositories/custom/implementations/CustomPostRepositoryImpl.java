package com.umugram.Tfg.repositories.custom.implementations;

import com.umugram.Tfg.domain.Post;
import com.umugram.Tfg.repositories.custom.CustomPostRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import java.util.List;
import com.umugram.Tfg.repositories.PostRepository;

public class CustomPostRepositoryImpl implements CustomPostRepository {
  @PersistenceContext private EntityManager entityManager;

  @Override
  public List<Post> cFindPostsWithLongCaptions(int minLength) {
    Query q =
        entityManager.createQuery("SELECT p FROM Post p WHERE LENGTH(p.caption) > :minLength");
    q.setParameter("minLength", minLength);
    return q.getResultList();
  }

  @Override
  public List<Post> cnFindAllLessUsers() {
    Query q = entityManager.createNamedQuery("Post.findAllLessUsers");
    return q.getResultList();
  }
}
