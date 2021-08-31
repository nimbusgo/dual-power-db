
const POSTGRAPHILE_USER_PASS = process.env.POSTGRAPHILE_USER_PASS || ""

module.exports.generateSql = () => `
CREATE ROLE IF NOT EXISTS dual_power_postgraphile login password '${POSTGRAPHILE_USER_PASS}';
`