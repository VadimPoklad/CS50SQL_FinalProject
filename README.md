# Design Document

CS50 SQL Course

Vadim Poklad

Video overview: <URL https://youtu.be/T8m_t6qaVmM>

## Scope

In this section you should answer the following questions:

* What is the purpose of your database?

The purpose of this database is to manage and organize various aspects of a music streaming service. It allows the service to store and access data related to songs, albums, artists, users, playlists, genres, and interactions, such as user subscriptions and likes. The database supports core functionalities, such as cataloging music, user management, playlist creation, and subscription handling.

* Which people, places, things, etc. are you including in the scope of your database?

People: Users of the music streaming service are within the scope of the database. This includes details about their subscriptions, playlists, and interactions like song likes.
Things: Music-related data is within the scope of the database, including songs, albums, artists, and genres.
Interactions: It tracks user interactions with the service, including creating playlists, liking songs, and subscribing to different service tiers.

* Which people, places, things, etc. are *outside* the scope of your database?

Financial Transactions: The database handles user subscription types and payment dates, but it does not appear to process financial transactions directly. The actual payment processing might be handled by external payment gateways.
Geographic Locations: The database doesn't include information about geographic locations or the physical distribution of music.
Music Content: While the database manages metadata about songs, albums, and artists, it likely does not store the actual music files. These files would typically be stored separately and referenced through links.
User Authentication and Security: Although the database stores user data, it doesn't detail the mechanisms for user authentication and security, such as password hashing and access control.


## Functional Requirements

In this section you should answer the following questions:

* What should a user be able to do with your database?

Browse Music: Users should be able to search for and access information about songs, albums, artists, and genres within the music catalog.
Create Playlists: Users can create and manage their playlists, adding songs from the catalog to their playlists.
Like Songs and Albums: Users should be able to like and save their favorite songs and albums for easy access.
Subscribe and Manage Subscriptions: Users can subscribe to different service tiers (e.g., free, premium, student) and manage their subscription status and payment dates.
Interact with User Profiles: Users can maintain their profiles, including updating their username and password.
Interact with Playlists: Users can add or remove songs from playlists, create both private and public playlists, and share public playlists with others.

* What's beyond the scope of what a user should be able to do with your database?

Stream Music: While the database stores metadata about songs and albums, it doesn't stream the actual music files. Streaming is typically managed by a separate music streaming service or server.
User Authentication: While users can manage their profiles, the database doesn't specify the authentication mechanism. User authentication and security are typically managed by an application layer, and the database would store user credentials in a secure manner.
User Interface: The database itself does not control the user interface. The user interface, including website or mobile app design, is developed separately from the database and interacts with the database to present data to users.
Content Licensing and Copyright: The database doesn't handle content licensing or copyright management. Music streaming services must negotiate licensing agreements with copyright holders, which are separate legal and business processes.
Content Upload: Adding new songs, albums, or artists to the catalog is typically not within the scope of a user's actions. This is usually managed by content administrators or providers who have the authority to add new content to the database.

## Representation

![schema](https://github.com/VadimPoklad/CS50SQL_FinalProject/assets/91690155/19db0bbe-08b9-4f27-a531-a131635fed4f)

### Entities

In this section you should answer the following questions:

* Which entities will you choose to represent in your database?

Songs, Albums, Genres, Artists, Users, Playlists
These entities cover the core aspects of a music-related application, including the music content (songs and albums), genre classifications, artists, user accounts, and playlists for organizing and curating music.

* What attributes will those entities have?

Songs Entity:
id, name, time, plays, song

Albums Entity:
id, name, year

Genres Entity:
id, name

Artists Entity:
id, name

Users Entity:
id, username, password, type, payment_date, payment_details

Playlists Entity:
id, name, type

These attributes are chosen to represent the essential information for each entity. For instance, in the "Users" entity, we store user-specific data such as the username, password, subscription type, payment information, etc.

* Why did you choose the types you did?

BIGINT for unique identifiers and large integer values.
VARCHAR for variable-length string data.
TIME for representing song durations.
YEAR for representing album release years.
ENUM for representing predefined subscription types.
DATE for date-related fields.
BLOB for binary data storage.

* Why did you choose the constraints you did?

PRIMARY KEY constraints ensure the uniqueness and quick retrieval of primary identifiers.
FOREIGN KEY constraints maintain referential integrity between related entities.
UNIQUE constraints ensure that certain attributes, like usernames, are unique.
NOT NULL constraints require the presence of essential data.
ENUM constraints limit values to predefined options for the "type" attribute.
DEFAULT constraints provide default values for specific attributes, such as the default user type and payment date.
Triggers and stored procedures are used to automate processes like subscription management and cascading deletes.

### Relationships

In this section you should include your entity relationship diagram and describe the relationships between the entities in your database.

## Optimizations

In this section you should answer the following questions:

* Which optimizations (e.g., indexes, views) did you create? Why?

The provided database schema includes essential optimizations such as indexes and views to enhance query performance. Indexes on columns like artist names, song names, and usernames speed up data retrieval. Views like "number_of_songs" and "albums_listening_count" simplify data access and improve the user experience. These optimizations are crucial for efficient database operations in a music streaming service.

## Limitations

In this section you should answer the following questions:

* What are the limitations of your design?

The limitations of the provided database design include potential scalability issues, data redundancy in many-to-many relationships, a complex structure that may be hard to maintain, and limited support for user profiles and streaming analytics.

* What might your database not be able to represent very well?

Scalability:
As the database grows with more users, songs, and albums, the performance might degrade. Indexes can help, but for very large datasets, additional optimization and sharding strategies might be necessary.

Security:
The script mentions saving password hashes using SHA-256, which is good, but security is an evolving field. Staying updated on the latest security practices is essential.

Data Volume:
Storing the actual song data as BLOBs in the database can be impractical for a large music library. It would be more efficient to store the songs in a file system or a cloud storage service and have references (e.g., file paths or URLs) in the database.

Data Redundancy:
The album_songs table creates a many-to-many relationship between albums and songs. While this is necessary to represent the fact that a song can belong to multiple albums, it may lead to data redundancy and inconsistency if not managed carefully.

Complexity:
The database is quite complex, with many relationships, views, stored procedures, and triggers. This complexity can make it challenging to maintain and troubleshoot. Documentation and clear naming conventions are essential.

Genre Handling:
The handling of genres is relatively simple in this design. If you need more detailed genre information or support for multiple genres per song, it might require a more complex structure.

Lack of User Profiles:
The database does not include user profile information beyond their username and subscription details. If you want to provide more extensive user profiles, you'd need to expand the users table.

Limited Playlist Metadata:
The playlists table lacks metadata about playlists beyond a name and type. Depending on the service's features, you might want to add more information, like descriptions or cover images.

No Support for Streaming Analytics:
If you want to gather user interaction data for analytics purposes, the database doesn't include tables or structures for that. Implementing such functionality would require additional schema changes.

Data Consistency Across Tables:
Ensuring data consistency across tables, especially when data changes in one table need to be reflected in related tables, can be complex. For example, when a song is liked, the like count should be updated in multiple places (e.g., song_likes, album_songs, albums).

No Support for Collaborative Features:
Collaborative features like sharing playlists and songs with other users are not represented in this design.
