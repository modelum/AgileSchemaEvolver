package com.umugram.Tfg;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import com.umugram.Tfg.domain.*;
import com.umugram.Tfg.repositories.*;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.*;

@SpringBootTest(classes = TfgApplication.class)
class UserRepositoryTests {

	@Autowired
	private UserRepository userRepository;
	
	@BeforeEach
	void init() {
		userRepository.deleteAll();
	}

	@Test
	void addUser()
	{
		// Arrange
		User manuel = new User("Manuel1", "contraseña2", LocalDate.of(2003, 3, 4), "manuel1@gmail.com");
		Profile manuProfile = new Profile("El manueh");
		manuProfile.setDescription("I love ice scream in the morning");
		manuProfile.setWebsite("elmanueh.es");
		manuel.setProfile(manuProfile);

		// Act
		userRepository.save(manuel);

		// Assert
		assertTrue(userRepository.existsById(manuel.getId()));
	}

	@Test
	void deleteUser() {
		// Arrange
		User manuel = new User("Manuel1", "contraseña2", LocalDate.of(2003, 3, 4), "manuel1@gmail.com");
		Profile manuProfile = new Profile("El manueh");
		manuProfile.setDescription("I love ice scream in the morning");
		manuProfile.setWebsite("elmanueh.es");
		manuel.setProfile(manuProfile);

		// Act
		userRepository.delete(manuel);

		// Assert
		assertNull(manuel.getId());
	}

	@Test
	void updateUser() {
		// Arrange
		User manuel = new User("Manuel1", "contraseña2", LocalDate.of(2003, 3, 4), "manuel1@gmail.com");
		Profile manuProfile = new Profile("El manueh");
		manuProfile.setDescription("I love ice scream in the morning");
		manuProfile.setWebsite("elmanueh.es");
		manuel.setProfile(manuProfile);
		userRepository.save(manuel);

		// Act
		manuel.setEmail("elmanueh@gmail.com");
		userRepository.save(manuel);

		// Assert
		assertEquals(manuel.getEmail(), "elmanueh@gmail.com");
	}

	@Test
	void userGiveFollow()
	{
		// Arrange
		User manuel = new User("Manuel1", "contraseña2", LocalDate.of(2003, 3, 4), "manuel1@gmail.com");
		Profile manuProfile = new Profile("El manueh");
		manuProfile.setDescription("I love ice scream in the morning");
		manuProfile.setWebsite("elmanueh.es");
		manuel.setProfile(manuProfile);
		userRepository.save(manuel);

		User paco = new User("Paco", "contraseña2", LocalDate.of(1998, 5, 12), "paco1@gmail.com");
		Profile pacoProfile = new Profile("Paco Sanchéz");
		pacoProfile.setDescription("I hate global injustices");
		pacoProfile.setAvatar_url("https://www.bobesponjaweb.com/wp-content/uploads/2014/11/Calamardo-2.jpg");
		paco.setProfile(pacoProfile);
		userRepository.save(paco);

		// Act
		manuel.addUsersFollowing(paco);
		paco.addUsersFollowing(manuel);
		userRepository.save(manuel);
		userRepository.save(paco);

		// Assert
		List<User> usersFollowingManuel = userRepository.findFollowingById(manuel.getId());
		List<User> followersPaco = userRepository.findFollowersById(paco.getId());
		assertEquals(usersFollowingManuel.get(0).getUsername(), "Paco");
		assertEquals(followersPaco.get(0).getUsername(), "Manuel1");
	}

	@Test
	void userUnfollow() {
		// Arrange
		User manuel = new User("Manuel1", "contraseña2", LocalDate.of(2003, 3, 4), "manuel1@gmail.com");
		Profile manuProfile = new Profile("El manueh");
		manuProfile.setDescription("I love ice scream in the morning");
		manuProfile.setWebsite("elmanueh.es");
		manuel.setProfile(manuProfile);
		userRepository.save(manuel);

		User paco = new User("Paco", "contraseña2", LocalDate.of(1998, 5, 12), "paco1@gmail.com");
		Profile pacoProfile = new Profile("Paco Sanchéz");
		pacoProfile.setDescription("I hate global injustices");
		pacoProfile.setAvatar_url("https://www.bobesponjaweb.com/wp-content/uploads/2014/11/Calamardo-2.jpg");
		paco.setProfile(pacoProfile);
		userRepository.save(paco);

		manuel.addUsersFollowing(paco);
		userRepository.save(manuel);

		// Act
		paco.removeFollower(manuel);

		// Assert
		List<User> usersFollowingManuel = userRepository.findFollowingById(manuel.getId());
		List<User> followersPaco = userRepository.findFollowersById(paco.getId());
		assertEquals(usersFollowingManuel.size(), 0);
		assertEquals(followersPaco.size(), 0);
	}

	@Test
	void testMutualFollow()
	{
		// Arrange
		User manuel = new User("Manuel1", "contraseña2", LocalDate.of(2003, 3, 4), "manuel1@gmail.com");
		Profile manuProfile = new Profile("El manueh");
		manuProfile.setDescription("I love ice scream in the morning");
		manuProfile.setWebsite("elmanueh.es");
		manuel.setProfile(manuProfile);
		userRepository.save(manuel);

		User paco = new User("Paco", "contraseña2", LocalDate.of(1998, 5, 12), "paco1@gmail.com");
		Profile pacoProfile = new Profile("Paco Sanchéz");
		pacoProfile.setDescription("I hate global injustices");
		pacoProfile.setAvatar_url("https://www.bobesponjaweb.com/wp-content/uploads/2014/11/Calamardo-2.jpg");
		paco.setProfile(pacoProfile);
		userRepository.save(paco);

		// Act
		manuel.addUsersFollowing(paco);
		paco.addUsersFollowing(manuel);

		userRepository.save(manuel);
		userRepository.save(paco);

		// Assert
		List<User> usersFollowingManuel = userRepository.findFollowingById(manuel.getId());
		List<User> userFollowingPaco = userRepository.findFollowingById(paco.getId());
		assertEquals(usersFollowingManuel.get(0).getUsername(), "Paco");
		assertEquals(userFollowingPaco.get(0).getUsername(), "Manuel1");

	}

}
