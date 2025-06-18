package com.umugram.Tfg.repositories.custom;

import com.umugram.Tfg.domain.Post;
import java.util.List;

public interface CustomPostRepository {
  List<Post> cFindPostsWithLongCaptions(int minLength);

  List<Post> cnFindAllLessUsers();
}
