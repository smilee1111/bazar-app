const mongoose = require("mongoose");
const colors = require("colors");
const dotenv = require("dotenv");
const Role = require("./models/role_model");
const User = require("./models/user_model");

// Load env vars
dotenv.config({ path: "./config/config.env" });

// Connect to database
const connectDB = async () => {
  const conn = await mongoose.connect(process.env.LOCAL_DATABASE_URI);
  console.log(`MongoDB Connected: ${conn.connection.host}`.cyan.underline.bold);
};

// Dummy data
const roles = [
  { roleName: "admin", status: "active" },
  { roleName: "user", status: "active" },
  { roleName: "seller", status: "active" },
];

const users = [
  {
    fullName: "Admin User",
    email: "admin@gmail.com",
    username: "admin",
    password: "password123",
  },
  {
    fullName: "Kiran Rana",
    email: "kiranrana@gmail.com",
    username: "kiranr",
    password: "password123",
  },
  {
    fullName: "Sarah Johnson",
    email: "sarah.johnson@gmail.com",
    username: "sarahj",
    password: "password123",
  },
  {
    fullName: "Michael Chen",
    email: "michael.chen@gmail.com",
    username: "mikechen",
    password: "password123",
  },
  {
    fullName: "Emily Rodriguez",
    email: "emily.rodriguez@gmail.com",
    username: "emilyrod",
    password: "password123",
  },
  {
    fullName: "James Wilson",
    email: "james.wilson@gmail.com",
    username: "jameswilson",
    password: "password123",
  },
  {
    fullName: "Priya Patel",
    email: "priya.patel@gmail.com",
    username: "priyap",
    password: "password123",
  },
  {
    fullName: "David Kim",
    email: "david.kim@gmail.com",
    username: "davidkim",
    password: "password123",
  },
  {
    fullName: "Olivia Martinez",
    email: "olivia.martinez@gmail.com",
    username: "oliviam",
    password: "password123",
  },
  {
    fullName: "Ryan Thompson",
    email: "ryan.thompson@gmail.com",
    username: "ryant",
    password: "password123",
  },
  {
    fullName: "Sophia Lee",
    email: "sophia.lee@gmail.com",
    username: "sophialee",
    password: "password123",
  },
  {
    fullName: "Alex Garcia",
    email: "alex.garcia@gmail.com",
    username: "alexg",
    password: "password123",
  },
  {
    fullName: "Emma Brown",
    email: "emma.brown@gmail.com",
    username: "emmab",
    password: "password123",
  },
  {
    fullName: "Daniel Singh",
    email: "daniel.singh@gmail.com",
    username: "daniels",
    password: "password123",
  },
];

// Import data
const importData = async () => {
  try {
    await connectDB();

    // Clear existing data
    await Role.deleteMany();
    await User.deleteMany();
    console.log("Data Destroyed...".red.inverse);

    // Create roles
    const createdRoles = await Role.insertMany(roles);
    console.log(`${createdRoles.length} Roles created`.green.inverse);

    // Assign roles to users and create them one by one to trigger password hashing
    const createdUsers = [];
    for (let i = 0; i < users.length; i++) {
      const userData = {
        ...users[i],
        roleId: i === 0 ? createdRoles[0]._id : createdRoles[1]._id, // First user is admin, rest are users
      };
      const user = await User.create(userData);
      createdUsers.push(user);
    }
    console.log(`${createdUsers.length} Users created`.green.inverse);

    console.log("\n✅ All data imported successfully!".green.bold);
    console.log("\n📊 Summary:".cyan.bold);
    console.log(`   Roles: ${createdRoles.length}`);
    console.log(`   Users: ${createdUsers.length}`);

    console.log(
      "\n🔑 Login Credentials (All passwords: password123):".yellow.bold
    );
    createdUsers.slice(0, 5).forEach((user, index) => {
      console.log(`   Email: ${user.email} | Username: ${user.username} | Role: ${index === 0 ? 'admin' : 'user'}`);
    });

    process.exit();
  } catch (error) {
    console.error(`Error: ${error}`.red.inverse);
    process.exit(1);
  }
};

// Delete data
const deleteData = async () => {
  try {
    await connectDB();

    await Role.deleteMany();
    await User.deleteMany();

    console.log("Data Destroyed...".red.inverse);
    process.exit();
  } catch (error) {
    console.error(`Error: ${error}`.red.inverse);
    process.exit(1);
  }
};

// Run functions based on command line argument
if (process.argv[2] === "-i") {
  importData();
} else if (process.argv[2] === "-d") {
  deleteData();
} else {
  console.log("Please use -i to import or -d to delete data".yellow);
  process.exit();
}
