const mongoose = require("mongoose");

const roleSchema = new mongoose.Schema({
  roleName: {
    type: String,
    required: [true, "Role name is required"],
    trim: true,
    unique: true,
    maxlength: [50, "Role name cannot exceed 50 characters"],
    minlength: [2, "Role name must be at least 2 characters"],
    index: true,
  },
  status: {
    type: String,
    enum: ["active", "completed", "cancelled"],
    default: "active",
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Role", roleSchema);
