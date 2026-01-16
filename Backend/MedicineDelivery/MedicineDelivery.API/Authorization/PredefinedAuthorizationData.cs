using System.Collections.ObjectModel;
using System.Linq;

namespace MedicineDelivery.API.Authorization
{
    /// <summary>
    /// Central place that describes the built-in roles, permissions and mappings.
    /// These definitions are referenced by the seeding endpoints so we avoid hard-coded values elsewhere.
    /// </summary>
    public static class PredefinedAuthorizationData
    {
        public const string AdminRoleId = "11111111-1111-1111-1111-111111111111";
        public const string ManagerRoleId = "22222222-2222-2222-2222-222222222222";
        public const string CustomerSupportRoleId = "33333333-3333-3333-3333-333333333333";
        public const string CustomerRoleId = "44444444-4444-4444-4444-444444444444";
        public const string ChemistRoleId = "55555555-5555-5555-5555-555555555555";

        public static IReadOnlyList<RoleSeedDefinition> Roles { get; } = new ReadOnlyCollection<RoleSeedDefinition>(
            new[]
            {
                new RoleSeedDefinition(AdminRoleId, "Admin"),
                new RoleSeedDefinition(ManagerRoleId, "Manager"),
                new RoleSeedDefinition(CustomerSupportRoleId, "CustomerSupport"),
                new RoleSeedDefinition(CustomerRoleId, "Customer"),
                new RoleSeedDefinition(ChemistRoleId, "Chemist")
            });

        public static IReadOnlyList<PermissionSeedDefinition> Permissions { get; } = new ReadOnlyCollection<PermissionSeedDefinition>(
            new[]
            {
                new PermissionSeedDefinition(1, "ReadUsers", "Users", "Can view user information"),
                new PermissionSeedDefinition(2, "CreateUsers", "Users", "Can create new users"),
                new PermissionSeedDefinition(3, "UpdateUsers", "Users", "Can update user information"),
                new PermissionSeedDefinition(4, "DeleteUsers", "Users", "Can delete users"),
                new PermissionSeedDefinition(5, "ReadProducts", "Products", "Can view products"),
                new PermissionSeedDefinition(6, "CreateProducts", "Products", "Can create new products"),
                new PermissionSeedDefinition(7, "UpdateProducts", "Products", "Can update products"),
                new PermissionSeedDefinition(8, "DeleteProducts", "Products", "Can delete products"),
                new PermissionSeedDefinition(13, "AdminReadUsers", "UserManagement", "Admin can view all user information"),
                new PermissionSeedDefinition(14, "AdminCreateUsers", "UserManagement", "Admin can create users"),
                new PermissionSeedDefinition(15, "AdminUpdateUsers", "UserManagement", "Admin can update user information"),
                new PermissionSeedDefinition(16, "AdminDeleteUsers", "UserManagement", "Admin can delete users"),
                new PermissionSeedDefinition(17, "ManagerReadUsers", "UserManagement", "Manager can view user information"),
                new PermissionSeedDefinition(18, "ManagerCreateUsers", "UserManagement", "Manager can create users"),
                new PermissionSeedDefinition(19, "ManagerUpdateUsers", "UserManagement", "Manager can update user information"),
                new PermissionSeedDefinition(20, "ManagerDeleteUsers", "UserManagement", "Manager can delete users"),
                new PermissionSeedDefinition(21, "CustomerSupportReadUsers", "UserManagement", "CustomerSupport can view user information"),
                new PermissionSeedDefinition(22, "CustomerSupportCreateUsers", "UserManagement", "CustomerSupport can create users"),
                new PermissionSeedDefinition(23, "CustomerSupportUpdateUsers", "UserManagement", "CustomerSupport can update user information"),
                new PermissionSeedDefinition(24, "CustomerSupportDeleteUsers", "UserManagement", "CustomerSupport can delete users"),
                new PermissionSeedDefinition(25, "ChemistReadUsers", "UserManagement", "Chemist can view user information"),
                new PermissionSeedDefinition(26, "ChemistCreateUsers", "UserManagement", "Chemist can create users"),
                new PermissionSeedDefinition(27, "ChemistUpdateUsers", "UserManagement", "Chemist can update user information"),
                new PermissionSeedDefinition(28, "ChemistDeleteUsers", "UserManagement", "Chemist can delete users"),
                new PermissionSeedDefinition(29, "ManageRolePermission", "RoleManagement", "Can manage role permissions"),
                new PermissionSeedDefinition(30, "ChemistRead", "Chemist", "Can read chemist information"),
                new PermissionSeedDefinition(31, "ChemistCreate", "Chemist", "Can create chemist accounts"),
                new PermissionSeedDefinition(32, "ChemistUpdate", "Chemist", "Can update chemist information"),
                new PermissionSeedDefinition(33, "ChemistDelete", "Chemist", "Can delete chemist accounts"),
                new PermissionSeedDefinition(34, "CustomerSupportRead", "CustomerSupport", "Can read customer support information"),
                new PermissionSeedDefinition(35, "CustomerSupportCreate", "CustomerSupport", "Can create customer support accounts"),
                new PermissionSeedDefinition(36, "CustomerSupportUpdate", "CustomerSupport", "Can update customer support information"),
                new PermissionSeedDefinition(37, "CustomerSupportDelete", "CustomerSupport", "Can delete customer support accounts"),
                new PermissionSeedDefinition(38, "ManagerSupportRead", "Manager", "Can read manager information"),
                new PermissionSeedDefinition(39, "ManagerSupportCreate", "Manager", "Can create manager accounts"),
                new PermissionSeedDefinition(40, "ManagerSupportUpdate", "Manager", "Can update manager information"),
                new PermissionSeedDefinition(41, "ManagerSupportDelete", "Manager", "Can delete manager accounts"),
                new PermissionSeedDefinition(42, "CustomerRead", "Customer", "Can read own customer information"),
                new PermissionSeedDefinition(43, "CustomerCreate", "Customer", "Can create customer accounts"),
                new PermissionSeedDefinition(44, "CustomerUpdate", "Customer", "Can update own customer information"),
                new PermissionSeedDefinition(45, "CustomerDelete", "Customer", "Can delete own customer account"),
                new PermissionSeedDefinition(46, "AllCustomerRead", "Customer", "Can read all customer information"),
                new PermissionSeedDefinition(47, "AllCustomerUpdate", "Customer", "Can update any customer information"),
                new PermissionSeedDefinition(48, "AllCustomerDelete", "Customer", "Can delete any customer account"),
                new PermissionSeedDefinition(49, "AllChemistRead", "Chemist", "Can read all chemist information"),
                new PermissionSeedDefinition(50, "AllChemistUpdate", "Chemist", "Can update any chemist information"),
                new PermissionSeedDefinition(51, "AllChemistDelete", "Chemist", "Can delete any chemist account"),
                new PermissionSeedDefinition(52, "ReadOrders", "Orders", "Can view orders"),
                new PermissionSeedDefinition(53, "CreateOrders", "Orders", "Can create orders"),
                new PermissionSeedDefinition(54, "UpdateOrders", "Orders", "Can update orders"),
                new PermissionSeedDefinition(55, "DeleteOrders", "Orders", "Can delete orders"),
                new PermissionSeedDefinition(56, "ListAllOrders", "Orders", "Can view all orders"),
                new PermissionSeedDefinition(57, "ReadConsents", "Consents", "Can view consents"),
                new PermissionSeedDefinition(58, "CreateConsents", "Consents", "Can create consents"),
                new PermissionSeedDefinition(59, "UpdateConsents", "Consents", "Can update consents"),
                new PermissionSeedDefinition(60, "DeleteConsents", "Consents", "Can delete consents"),
                new PermissionSeedDefinition(61, "ReadConsentLogs", "Consents", "Can view consent logs")
            });

        private static readonly IReadOnlyDictionary<string, string[]> RolePermissionNames = new ReadOnlyDictionary<string, string[]>(
            new Dictionary<string, string[]>
            {
                [AdminRoleId] = Permissions.Select(p => p.Name).ToArray(),
                [ManagerRoleId] = new[]
                {
                    "ReadUsers", "UpdateUsers", "ReadProducts", "UpdateProducts",
                    "ManagerReadUsers", "ManagerCreateUsers", "ManagerUpdateUsers", "ManagerDeleteUsers",
                    "CustomerSupportReadUsers", "CustomerSupportCreateUsers", "CustomerSupportUpdateUsers", "CustomerSupportDeleteUsers",
                    "ChemistReadUsers", "ChemistCreateUsers", "ChemistUpdateUsers", "ChemistDeleteUsers",
                    "ChemistRead", "ChemistCreate", "ChemistUpdate", "ChemistDelete",
                    "CustomerSupportRead", "CustomerSupportCreate", "CustomerSupportUpdate", "CustomerSupportDelete",
                    "ManagerSupportRead", "ManagerSupportUpdate", "ManagerSupportDelete",
                    "AllCustomerRead", "AllCustomerUpdate", "AllCustomerDelete",
                    "CustomerCreate",
                    "AllChemistRead", "AllChemistUpdate", "AllChemistDelete",
                    "ReadOrders", "CreateOrders", "UpdateOrders", "DeleteOrders", "ListAllOrders",
                    "ReadConsents", "CreateConsents", "UpdateConsents", "DeleteConsents", "ReadConsentLogs"
                },
                [CustomerSupportRoleId] = new[]
                {
                    "ReadProducts",
                    "CustomerSupportReadUsers", "CustomerSupportCreateUsers", "CustomerSupportUpdateUsers", "CustomerSupportDeleteUsers",
                    "ChemistReadUsers", "ChemistCreateUsers", "ChemistUpdateUsers", "ChemistDeleteUsers",
                    "ChemistRead", "ChemistCreate", "ChemistUpdate", "ChemistDelete",
                    "CustomerSupportRead", "CustomerSupportUpdate", "CustomerSupportDelete",
                    "AllCustomerRead", "AllCustomerUpdate", "AllCustomerDelete",
                    "CustomerCreate",
                    "AllChemistRead", "AllChemistUpdate", "AllChemistDelete",
                    "ReadOrders", "CreateOrders", "UpdateOrders"
                },
                [CustomerRoleId] = new[]
                {
                    "ReadProducts",
                    "CustomerRead", "CustomerUpdate", "CustomerDelete", "ReadOrders", "CreateOrders", "UpdateOrders","CustomerCreate",
                },
                [ChemistRoleId] = new[]
                {
                    "ReadProducts", "CreateProducts", "UpdateProducts", "DeleteProducts",
                    "ChemistRead", "ChemistUpdate", "ChemistDelete", "ReadOrders", "CreateOrders", "UpdateOrders"
                }
            });

        public static IReadOnlyDictionary<string, IReadOnlyCollection<int>> RolePermissions =>
            new ReadOnlyDictionary<string, IReadOnlyCollection<int>>(
                RolePermissionNames.ToDictionary(
                    pair => pair.Key,
                    pair => (IReadOnlyCollection<int>)pair.Value
                        .Select(name => Permissions.Single(p => p.Name == name).Id)
                        .ToArray()));

        public sealed record RoleSeedDefinition(string Id, string Name)
        {
            public string NormalizedName => Name.ToUpperInvariant();
        }

        public sealed record PermissionSeedDefinition(int Id, string Name, string Module, string Description);
    }
}

