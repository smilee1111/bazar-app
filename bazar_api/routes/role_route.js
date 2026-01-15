const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");

const {
  createRole,
  getAllRoles,
  getRoleById,
  updateRole,
} = require("../controllers/role_controller");

router.post("/", protect, createRole);
router.get("/", getAllRoles);
router.get("/:id", getRoleById);
router.put("/:id", protect, updateRole);

module.exports = router;
