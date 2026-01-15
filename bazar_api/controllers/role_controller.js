const asyncHandler = require("../middleware/async");
const role = require("../models/role_model");

// @desc    Create a new role
// @route   POST /api/roles
// @access  Private (Admin)

exports.createRole = asyncHandler(async (req, res) => {
  const { roleName, status } = req.body;

  if (!roleName || typeof roleName !== "string") {
    return res.status(400).json({
      success: false,
      message: "role name is required",
    });
  }

  const role = await role.create({
    roleName: roleName.trim(),
    status,
  });

  res.status(201).json({
    success: true,
    data: role,
  });
});

// @desc    Get all roles
// @route   GET /api/roles
// @access  Private (Admin)

exports.getAllRoles = asyncHandler(async (req, res) => {
  const roles = await role.find();

  res.status(200).json({
    success: true,
    count: roles.length,
    data: roles,
  });
});

// @desc    Get a single role by ID
// @route   GET /api/roles/:id
// @access  Private (Admin)

exports.getRoleById = asyncHandler(async (req, res) => {
  const role = await role.findById(req.params.id);

  if (!role) {
    return res.status(404).json({ message: "role not found" });
  }

  res.status(200).json({
    success: true,
    data: role,
  });
});

// @desc    Update a role by ID
// @route   PUT /api/roles/:id
// @access  Private (Admin)

exports.updateRole = asyncHandler(async (req, res) => {
  const { roleName } = req.body;

  const role = await role.findByIdAndUpdate(
    req.params.id,
    { roleName },
    { new: true, runValidators: true }
  );

  if (!role) {
    return res.status(404).json({ message: "role not found" });
  }

  res.status(200).json({
    success: true,
    data: role,
  });
});
