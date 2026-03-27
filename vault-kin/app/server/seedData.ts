import { db } from "./storage";
import { sections, categories } from "@shared/schema";

interface FieldDef {
  id: string;
  label: string;
  type: "text" | "secureText" | "number" | "currency" | "date" | "dropdown" | "toggle" | "multiline" | "phone" | "email" | "url";
  priority: "required" | "recommended" | "optional";
  helpText?: string;
  placeholder?: string;
  options?: string[];
}

interface FieldGroup {
  id: string;
  label: string;
  fields: FieldDef[];
}

interface FieldSchema {
  groups: FieldGroup[];
}

interface CategoryDef {
  name: string;
  type: "single" | "multi";
  guidanceText: string;
  iconName: string;
  fieldSchema: FieldSchema;
}

interface SectionDef {
  name: string;
  icon: string;
  description: string;
  categories: CategoryDef[];
}

const SECTIONS: SectionDef[] = [
  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 1: Getting Started
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Getting Started",
    icon: "Rocket",
    description: "Set up your vault and capture the most critical information first.",
    categories: [
      {
        name: "Welcome & Guided Setup",
        type: "single",
        guidanceText: "Welcome to VaultKin! This section helps you get oriented and begin organizing your life information.",
        iconName: "HandHeart",
        fieldSchema: {
          groups: [
            {
              id: "welcome",
              label: "Welcome",
              fields: [
                { id: "welcomeMessage", label: "Welcome Message", type: "multiline", priority: "optional", helpText: "A personal welcome note or reminder of why you started this vault" },
                { id: "gettingStartedGuide", label: "Getting Started Guide", type: "multiline", priority: "optional", helpText: "Notes on how to best use VaultKin for your needs" },
              ],
            },
          ],
        },
      },
      {
        name: "Crucial Information",
        type: "single",
        guidanceText: "Record the most important identifying information about yourself. This is what your next of kin will need first.",
        iconName: "ShieldAlert",
        fieldSchema: {
          groups: [
            {
              id: "identity",
              label: "Personal Identity",
              fields: [
                { id: "fullName", label: "Full Legal Name", type: "text", priority: "required", placeholder: "First Middle Last" },
                { id: "dateOfBirth", label: "Date of Birth", type: "date", priority: "required" },
                { id: "ssn", label: "Social Security Number", type: "secureText", priority: "recommended", helpText: "Stored securely — only revealed when you choose" },
                { id: "driversLicenseNumber", label: "Driver's License Number", type: "text", priority: "recommended", placeholder: "License number" },
                { id: "driversLicenseState", label: "State issued", type: "text", priority: "recommended",  placeholder: "State" },
                { id: "driversLicenseDateOfExpiration", label: "Expiration Date", type: "date", priority: "recommended" },
                { id: "passportNumber", label: "Passport Number", type: "text", priority: "optional", placeholder: "Passport number" },
                { id: "passportCountry", label: "Country", type: "text", priority: "recommended", placeholder: "Country" },
                { id: "passportDateOfExpiration", label: "Expiration Date", type: "date", priority: "recommended" },
              ],
            },
            {
              id: "emergency",
              label: "Emergency Contact",
              fields: [
                { id: "emergencyContactName", label: "Emergency Contact Name", type: "text", priority: "required", placeholder: "Full name" },
                { id: "emergencyContactPhone", label: "Emergency Contact Phone", type: "phone", priority: "required", placeholder: "(555) 123-4567" },
                { id: "emergencyContactRelationship", label: "Relationship", type: "text", priority: "required", placeholder: "e.g., Spouse, Sibling, Friend" },
              ],
            },
          ],
        },
      },
      {
        name: "Letter to NOK",
        type: "single",
        guidanceText: "Write a personal letter to your next of kin. This can include wishes, instructions, or simply a message from the heart.",
        iconName: "MailHeart",
        fieldSchema: {
          groups: [
            {
              id: "letter",
              label: "Your Letter",
              fields: [
                { id: "letterContent", label: "Letter Content", type: "multiline", priority: "recommended", helpText: "Write your personal message here. Take your time — you can always come back to edit.", placeholder: "Dear family..." },
                { id: "lastUpdated", label: "Last Updated", type: "date", priority: "optional", helpText: "When you last revised this letter" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 2: Your Home
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Your Home",
    icon: "Home",
    description: "Everything about where you live — property details, utilities, maintenance, access, and inventory.",
    categories: [
      {
        name: "Primary Residence",
        type: "single",
        guidanceText: "Record details about your primary home, including mortgage and insurance information.",
        iconName: "House",
        fieldSchema: {
          groups: [
            {
              id: "address",
              label: "Property Address",
              fields: [
                { id: "address", label: "Street Address", type: "text", priority: "required", placeholder: "123 Main St" },
                { id: "city", label: "City", type: "text", priority: "required", placeholder: "City" },
                { id: "state", label: "State", type: "text", priority: "required", placeholder: "State" },
                { id: "zip", label: "ZIP Code", type: "text", priority: "required", placeholder: "12345" },
                { id: "county", label: "County", type: "text", priority: "optional", placeholder: "County name" },
                { id: "propertyType", label: "Property Type", type: "dropdown", priority: "recommended", options: ["Single Family", "Condo", "Townhouse", "Apartment", "Mobile Home", "Other"] },
              ],
            },
            {
              id: "ownership",
              label: "Ownership & Mortgage",
              fields: [
                { id: "dateOfPurchase", label: "Date Purchased", type: "date", priority: "recommended", placeholder: "Date purchased" },
                { id: "mortgageCompany", label: "Mortgage Company", type: "text", priority: "recommended", placeholder: "Lender name" },
                { id: "mortgageAccountNumber", label: "Mortgage Account Number", type: "secureText", priority: "recommended" },
                { id: "monthlyPayment", label: "Monthly Payment", type: "currency", priority: "optional" },
                { id: "mortgageMaturityDate", label: "Maturity Date", type: "date", priority: "optional" },
              ],
            },
            {
              id: "insurance_tax",
              label: "Insurance & Taxes",
              fields: [
                { id: "propertyTaxAuthority", label: "Property Tax Authority", type: "text", priority: "optional", placeholder: "County tax office" },
                { id: "annualPropertyTax", label: "Annual Property Tax", type: "currency", priority: "optional" },
                { id: "propertyTaxDueDate", label: "Due date", type: "date", priority: "recommended" },
                { id: "homeInsuranceProvider", label: "Home Insurance Provider", type: "text", priority: "recommended", placeholder: "Insurance company" },
                { id: "homeInsurancePolicyNumber", label: "Home Insurance Policy Number", type: "text", priority: "recommended" },
                { id: "homeInsurancePolicyStartDate", label: "Start date", type: "date", priority: "recommended" },
                { id: "homeInsurancePolicyEndDate", label: "End date", type: "date", priority: "recommended" },
              ],
            },
          ],
        },
      },
      {
        name: "Utilities & HOA",
        type: "multi",
        guidanceText: "List each utility service and any HOA or community fees. Add one entry per utility or service.",
        iconName: "Zap",
        fieldSchema: {
          groups: [
            {
              id: "utility_info",
              label: "Utility Information",
              fields: [
                { id: "utilityName", label: "Utility/Service Name", type: "text", priority: "required", placeholder: "e.g., Electric, Gas, Water, Internet, HOA" },
                { id: "provider", label: "Provider/Company", type: "text", priority: "required", placeholder: "Company name" },
                { id: "accountNumber", label: "Account Number", type: "text", priority: "recommended" },
                { id: "website", label: "Website", type: "url", priority: "optional", placeholder: "https://" },
                { id: "username", label: "Online Username", type: "text", priority: "optional" },
                { id: "monthlyAmount", label: "Monthly Amount", type: "currency", priority: "optional" },
                { id: "autopay", label: "Autopay Enabled", type: "toggle", priority: "optional", helpText: "Is this set up for automatic payment?" },
                { id: "utilityDueDate", label: "Due date", type: "date", priority: "recommended" },
                { id: "contactPhone", label: "Contact Phone", type: "phone", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Maintenance Log",
        type: "multi",
        guidanceText: "Track home repairs, services, and scheduled maintenance. One entry per service or repair.",
        iconName: "Wrench",
        fieldSchema: {
          groups: [
            {
              id: "maintenance",
              label: "Maintenance Details",
              fields: [
                { id: "description", label: "Description", type: "text", priority: "required", placeholder: "e.g., HVAC serviced, Roof repair" },
                { id: "provider", label: "Service Provider", type: "text", priority: "recommended", placeholder: "Company or person" },
                { id: "providerPhone", label: "Provider Phone", type: "phone", priority: "optional" },
                { id: "date", label: "Date of Service", type: "date", priority: "recommended" },
                { id: "cost", label: "Cost", type: "currency", priority: "optional" },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional" },
                { id: "nextDueDate", label: "Next Due Date", type: "date", priority: "optional", helpText: "When is this service next due?" },
              ],
            },
          ],
        },
      },
      {
        name: "People & Access",
        type: "multi",
        guidanceText: "Who has access to your home? Record people, their roles, and any access codes they need.",
        iconName: "KeyRound",
        fieldSchema: {
          groups: [
            {
              id: "person",
              label: "Person Details",
              fields: [
                { id: "personName", label: "Name", type: "text", priority: "required", placeholder: "Full name" },
                { id: "role", label: "Role", type: "text", priority: "required", placeholder: "e.g., Neighbor, Housekeeper, Pet Sitter" },
                { id: "phone", label: "Phone", type: "phone", priority: "recommended" },
                { id: "email", label: "Email", type: "email", priority: "optional" },
              ],
            },
            {
              id: "access",
              label: "Access Information",
              fields: [
                { id: "hasKey", label: "Has Key", type: "toggle", priority: "recommended" },
                { id: "alarmCode", label: "Alarm Code", type: "secureText", priority: "optional" },
                { id: "gateCode", label: "Gate Code", type: "secureText", priority: "optional" },
                { id: "garageCode", label: "Garage Code", type: "secureText", priority: "optional" },
                { id: "wifiPassword", label: "WiFi Password", type: "secureText", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Home Inventory",
        type: "multi",
        guidanceText: "Document valuable items in your home for insurance and estate purposes. One entry per item or group.",
        iconName: "Package",
        fieldSchema: {
          groups: [
            {
              id: "item",
              label: "Item Details",
              fields: [
                { id: "itemName", label: "Item Name", type: "text", priority: "required", placeholder: "e.g., Engagement Ring, Grand Piano" },
                { id: "category", label: "Category", type: "dropdown", priority: "recommended", options: ["Electronics", "Jewelry", "Furniture", "Art", "Collectibles", "Appliances", "Musical Instruments", "Tools", "Sporting Goods", "Other"] },
                { id: "location", label: "Location in Home", type: "text", priority: "recommended", placeholder: "e.g., Master bedroom safe" },
                { id: "estimatedValue", label: "Estimated Value", type: "currency", priority: "recommended" },
                { id: "purchaseDate", label: "Purchase Date", type: "date", priority: "optional" },
                { id: "serialNumber", label: "Serial Number", type: "text", priority: "optional" },
                { id: "photoAttached", label: "Photo Attached", type: "toggle", priority: "optional", helpText: "Have you taken a photo of this item?" },
                { id: "insuranceRider", label: "Insurance Rider", type: "toggle", priority: "optional", helpText: "Is this item covered by a special insurance rider?" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 3: Vehicles
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Vehicles",
    icon: "Car",
    description: "Details for each vehicle you own or lease — registration, insurance, loans, and location.",
    categories: [
      {
        name: "Vehicle",
        type: "multi",
        guidanceText: "Add one entry for each vehicle you own, lease, or regularly use. Include all relevant details for your next of kin.",
        iconName: "Car",
        fieldSchema: {
          groups: [
            {
              id: "vehicle_details",
              label: "Vehicle Details",
              fields: [
                { id: "year", label: "Year", type: "text", priority: "required", placeholder: "2023" },
                { id: "make", label: "Make", type: "text", priority: "required", placeholder: "e.g., Toyota" },
                { id: "model", label: "Model", type: "text", priority: "required", placeholder: "e.g., Camry" },
                { id: "color", label: "Color", type: "text", priority: "optional", placeholder: "e.g., Silver" },
                { id: "vin", label: "VIN", type: "text", priority: "recommended", helpText: "Vehicle Identification Number — 17 characters" },
                { id: "licensePlate", label: "License Plate", type: "text", priority: "recommended" },
                { id: "registrationState", label: "Registration State", type: "text", priority: "recommended" },
                { id: "vehicleRegistrationExpires", label: "Registration expires", type: "date", priority: "recommended" },
              ],
            },
            {
              id: "ownership_finance",
              label: "Ownership & Financing",
              fields: [
                { id: "titleHolder", label: "Title Holder", type: "text", priority: "recommended", placeholder: "Name on title" },
                { id: "lienHolder", label: "Lien Holder", type: "text", priority: "optional", placeholder: "Bank or finance company" },
                { id: "paymentAmount", label: "Monthly Payment", type: "currency", priority: "optional" },
                { id: "paymentFrequency", label: "Payment Frequency", type: "dropdown", priority: "optional", options: ["Monthly", "Bi-weekly", "Weekly", "Paid Off"] },
                { id: "loanAccountNumber", label: "Loan Account Number", type: "secureText", priority: "optional" },
                { id: "vehicleLoanMaturityDate", label: "Maturity Date", type: "date", priority: "optional" },
              ],
            },
            {
              id: "insurance_location",
              label: "Insurance & Location",
              fields: [
                { id: "insuranceCompany", label: "Insurance Company", type: "text", priority: "recommended" },
                { id: "insurancePolicyNumber", label: "Insurance Policy Number", type: "text", priority: "recommended" },
                { id: "insuranceAgentPhone", label: "Insurance Agent Phone", type: "phone", priority: "optional" },
                { id: "vehicleInsurancePolicyStartDate", label: "Start date", type: "date", priority: "recommended" },
                { id: "vehicleInsurancePolicyEndDate", label: "End date", type: "date", priority: "recommended" },
                { id: "whereParked", label: "Where Normally Parked", type: "text", priority: "optional", placeholder: "e.g., Home garage, office parking deck" },
                { id: "keyLocation", label: "Key/Fob Location", type: "text", priority: "optional", placeholder: "e.g., Kitchen hook, entry table" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 4: Banking & Money
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Banking & Money",
    icon: "Landmark",
    description: "All your bank accounts, debit cards, and digital payment apps.",
    categories: [
      {
        name: "Bank Accounts",
        type: "multi",
        guidanceText: "Record each bank account you have. Include access credentials and beneficiary information so your next of kin can manage these accounts.",
        iconName: "Building2",
        fieldSchema: {
          groups: [
            {
              id: "bank_info",
              label: "Bank Information",
              fields: [
                { id: "bankName", label: "Bank Name", type: "text", priority: "required", placeholder: "e.g., Chase, Bank of America" },
                { id: "website", label: "Website", type: "url", priority: "optional", placeholder: "https://" },
                { id: "branch", label: "Branch Location", type: "text", priority: "optional", placeholder: "City or branch name" },
              ],
            },
            {
              id: "account_details",
              label: "Account Details",
              fields: [
                { id: "accountType", label: "Account Type", type: "dropdown", priority: "required", options: ["Checking", "Savings", "Money Market", "CD", "Other"] },
                { id: "accountName", label: "Account Nickname", type: "text", priority: "optional", placeholder: "e.g., Joint Checking, Emergency Fund" },
                { id: "accountNumber", label: "Account Number", type: "secureText", priority: "required" },
                { id: "routingNumber", label: "Routing Number", type: "text", priority: "recommended" },
                { id: "approximateBalance", label: "Approximate Balance", type: "currency", priority: "optional" },
              ],
            },
            {
              id: "access",
              label: "Online Access",
              fields: [
                { id: "onlineUsername", label: "Online Username", type: "text", priority: "recommended" },
                { id: "onlinePassword", label: "Online Password", type: "secureText", priority: "optional", helpText: "Consider using a password manager reference instead" },
              ],
            },
            {
              id: "beneficiary",
              label: "Beneficiary & Autopay",
              fields: [
                { id: "beneficiary", label: "Beneficiary", type: "text", priority: "recommended", placeholder: "Name of designated beneficiary" },
                { id: "autopayments", label: "Autopayments Linked", type: "multiline", priority: "optional", helpText: "List any bills automatically paid from this account" },
              ],
            },
          ],
        },
      },
      {
        name: "Debit Cards",
        type: "multi",
        guidanceText: "Record details for each debit card. This helps your next of kin identify and manage your banking cards.",
        iconName: "CreditCard",
        fieldSchema: {
          groups: [
            {
              id: "card_info",
              label: "Card Information",
              fields: [
                { id: "bankName", label: "Bank Name", type: "text", priority: "required", placeholder: "Issuing bank" },
                { id: "cardNumber", label: "Card Number", type: "secureText", priority: "recommended", helpText: "Last 4 digits may be sufficient" },
                { id: "nameOnCard", label: "Name on Card", type: "text", priority: "recommended" },
                { id: "expirationDate", label: "Expiration Date", type: "text", priority: "optional", placeholder: "MM/YY" },
                { id: "pin", label: "PIN", type: "secureText", priority: "optional", helpText: "Store securely — only reveal when needed" },
              ],
            },
          ],
        },
      },
      {
        name: "Money Apps",
        type: "multi",
        guidanceText: "Digital wallets and payment apps like Venmo, PayPal, Zelle, Cash App, etc.",
        iconName: "Smartphone",
        fieldSchema: {
          groups: [
            {
              id: "app_info",
              label: "App Details",
              fields: [
                { id: "appName", label: "App Name", type: "text", priority: "required", placeholder: "e.g., Venmo, PayPal, Cash App" },
                { id: "username", label: "Username", type: "text", priority: "recommended" },
                { id: "email", label: "Linked Email", type: "email", priority: "recommended" },
                { id: "phone", label: "Linked Phone", type: "phone", priority: "optional" },
                { id: "linkedBankAccount", label: "Linked Bank Account", type: "text", priority: "optional", placeholder: "Which bank account is connected?" },
                { id: "balance", label: "Approximate Balance", type: "currency", priority: "optional" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 5: Insurance
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Insurance",
    icon: "Shield",
    description: "All your insurance policies in one place — health, auto, home, life, and more.",
    categories: [
      {
        name: "Insurance Policies",
        type: "multi",
        guidanceText: "Add one entry for each insurance policy you hold. Include agent contact info and renewal dates.",
        iconName: "ShieldCheck",
        fieldSchema: {
          groups: [
            {
              id: "policy_type",
              label: "Policy Type & Provider",
              fields: [
                { id: "insuranceType", label: "Insurance Type", type: "dropdown", priority: "required", options: ["Health", "Auto", "Home", "Life", "Umbrella", "Long-term Care", "Disability", "Dental", "Vision", "Pet", "Travel", "Other"] },
                { id: "company", label: "Insurance Company", type: "text", priority: "required", placeholder: "Company name" },
                { id: "policyNumber", label: "Policy Number", type: "text", priority: "required" },
              ],
            },
            {
              id: "coverage",
              label: "Coverage & Cost",
              fields: [
                { id: "premium", label: "Premium Amount", type: "currency", priority: "recommended" },
                { id: "premiumFrequency", label: "Premium Frequency", type: "dropdown", priority: "recommended", options: ["Monthly", "Quarterly", "Semi-annually", "Annually"] },
                { id: "deductible", label: "Deductible", type: "currency", priority: "optional" },
                { id: "coverageAmount", label: "Coverage Amount", type: "currency", priority: "recommended" },
                { id: "beneficiary", label: "Beneficiary", type: "text", priority: "recommended", placeholder: "Named beneficiary" },
                { id: "renewalDate", label: "Renewal Date", type: "date", priority: "optional" },
              ],
            },
            {
              id: "agent",
              label: "Agent & Access",
              fields: [
                { id: "agentName", label: "Agent Name", type: "text", priority: "optional" },
                { id: "agentPhone", label: "Agent Phone", type: "phone", priority: "optional" },
                { id: "agentEmail", label: "Agent Email", type: "email", priority: "optional" },
                { id: "websiteLogin", label: "Website/Portal Login", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 6: Investments
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Investments",
    icon: "TrendingUp",
    description: "Retirement accounts, brokerage accounts, 529 plans, HSAs, and other investments.",
    categories: [
      {
        name: "Investment Accounts",
        type: "multi",
        guidanceText: "Record each investment or retirement account. Include advisor information and beneficiary designations.",
        iconName: "LineChart",
        fieldSchema: {
          groups: [
            {
              id: "account_info",
              label: "Account Information",
              fields: [
                { id: "institution", label: "Institution", type: "text", priority: "required", placeholder: "e.g., Fidelity, Vanguard, Schwab" },
                { id: "accountType", label: "Account Type", type: "dropdown", priority: "required", options: ["401(k)", "403(b)", "Traditional IRA", "Roth IRA", "SEP IRA", "Brokerage", "529 Plan", "HSA", "Pension", "Annuity", "Other"] },
                { id: "accountNumber", label: "Account Number", type: "secureText", priority: "recommended" },
                { id: "estimatedValue", label: "Estimated Value", type: "currency", priority: "recommended" },
              ],
            },
            {
              id: "beneficiary_advisor",
              label: "Beneficiary & Advisor",
              fields: [
                { id: "beneficiary", label: "Beneficiary", type: "text", priority: "recommended", placeholder: "Primary beneficiary" },
                { id: "contingentBeneficiary", label: "Contingent Beneficiary", type: "text", priority: "optional" },
                { id: "financialAdvisor", label: "Financial Advisor", type: "text", priority: "optional" },
                { id: "advisorPhone", label: "Advisor Phone", type: "phone", priority: "optional" },
                { id: "advisorEmail", label: "Advisor Email", type: "email", priority: "optional" },
              ],
            },
            {
              id: "access",
              label: "Online Access",
              fields: [
                { id: "websiteLogin", label: "Website/Portal", type: "url", priority: "optional" },
                { id: "username", label: "Username", type: "text", priority: "optional" },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 7: Credit & Debt
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Credit & Debt",
    icon: "CreditCard",
    description: "Credit cards, student loans, personal loans, and medical debt.",
    categories: [
      {
        name: "Major Credit Cards",
        type: "multi",
        guidanceText: "Record each major credit card (Visa, Mastercard, Amex, Discover). Include payment and rewards details.",
        iconName: "CreditCard",
        fieldSchema: {
          groups: [
            {
              id: "card_info",
              label: "Card Information",
              fields: [
                { id: "issuer", label: "Issuer", type: "text", priority: "required", placeholder: "e.g., Chase Sapphire, Amex Gold" },
                { id: "cardNumber", label: "Card Number", type: "secureText", priority: "recommended", helpText: "Last 4 digits may be sufficient" },
                { id: "expirationDate", label: "Expiration Date", type: "text", priority: "optional", placeholder: "MM/YY" },
                { id: "nameOnCard", label: "Name on Card", type: "text", priority: "recommended" },
                { id: "creditLimit", label: "Credit Limit", type: "currency", priority: "optional" },
                { id: "balance", label: "Current Balance", type: "currency", priority: "optional" },
              ],
            },
            {
              id: "payment",
              label: "Payment Details",
              fields: [
                { id: "minimumPayment", label: "Minimum Payment", type: "currency", priority: "optional" },
                { id: "dueDate", label: "Payment Due Date", type: "text", priority: "recommended", placeholder: "Day of month, e.g., 15th" },
                { id: "interestRate", label: "Interest Rate (APR)", type: "text", priority: "optional", placeholder: "e.g., 18.99%" },
                { id: "autopaySetup", label: "Autopay Setup", type: "toggle", priority: "optional" },
              ],
            },
            {
              id: "rewards",
              label: "Rewards & Access",
              fields: [
                { id: "rewardsProgram", label: "Rewards Program", type: "text", priority: "optional", placeholder: "e.g., Chase Ultimate Rewards" },
                { id: "websiteLogin", label: "Website/Portal", type: "url", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Retail Credit Cards",
        type: "multi",
        guidanceText: "Store credit cards from specific retailers (Target, Amazon, etc.).",
        iconName: "ShoppingBag",
        fieldSchema: {
          groups: [
            {
              id: "card_info",
              label: "Card Information",
              fields: [
                { id: "store", label: "Store/Retailer", type: "text", priority: "required", placeholder: "e.g., Target, Amazon" },
                { id: "cardNumber", label: "Card Number", type: "secureText", priority: "optional" },
                { id: "expirationDate", label: "Expiration Date", type: "text", priority: "optional", placeholder: "MM/YY" },
                { id: "creditLimit", label: "Credit Limit", type: "currency", priority: "optional" },
                { id: "balance", label: "Current Balance", type: "currency", priority: "optional" },
                { id: "minimumPayment", label: "Minimum Payment", type: "currency", priority: "optional" },
                { id: "dueDate", label: "Payment Due Date", type: "text", priority: "optional", placeholder: "Day of month" },
              ],
            },
          ],
        },
      },
      {
        name: "Student Debt",
        type: "multi",
        guidanceText: "Record each student loan — federal and private.",
        iconName: "GraduationCap",
        fieldSchema: {
          groups: [
            {
              id: "loan_info",
              label: "Loan Information",
              fields: [
                { id: "lender", label: "Lender/Servicer", type: "text", priority: "required", placeholder: "e.g., Nelnet, Great Lakes, SoFi" },
                { id: "loanType", label: "Loan Type", type: "dropdown", priority: "recommended", options: ["Federal Direct", "Federal PLUS", "Federal Perkins", "Private", "Consolidated", "Other"] },
                { id: "accountNumber", label: "Account Number", type: "text", priority: "recommended" },
                { id: "originalAmount", label: "Original Amount", type: "currency", priority: "optional" },
                { id: "currentBalance", label: "Current Balance", type: "currency", priority: "recommended" },
                { id: "monthlyPayment", label: "Monthly Payment", type: "currency", priority: "recommended" },
                { id: "interestRate", label: "Interest Rate", type: "text", priority: "optional", placeholder: "e.g., 5.5%" },
                { id: "expectedPayoffDate", label: "Expected Payoff Date", type: "date", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Personal Loans",
        type: "multi",
        guidanceText: "Record personal loans, home equity loans, or lines of credit.",
        iconName: "HandCoins",
        fieldSchema: {
          groups: [
            {
              id: "loan_info",
              label: "Loan Details",
              fields: [
                { id: "lender", label: "Lender", type: "text", priority: "required", placeholder: "Bank or lender name" },
                { id: "loanType", label: "Loan Type", type: "dropdown", priority: "optional", options: ["Personal Loan", "Home Equity Loan", "HELOC", "Line of Credit", "Other"] },
                { id: "accountNumber", label: "Account Number", type: "text", priority: "recommended" },
                { id: "originalAmount", label: "Original Amount", type: "currency", priority: "optional" },
                { id: "currentBalance", label: "Current Balance", type: "currency", priority: "recommended" },
                { id: "monthlyPayment", label: "Monthly Payment", type: "currency", priority: "recommended" },
                { id: "interestRate", label: "Interest Rate", type: "text", priority: "optional" },
                { id: "collateral", label: "Collateral", type: "text", priority: "optional", placeholder: "What secures this loan, if any?" },
                { id: "expectedPayoffDate", label: "Expected Payoff Date", type: "date", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Medical Debt",
        type: "multi",
        guidanceText: "Record outstanding medical bills or payment plans.",
        iconName: "Stethoscope",
        fieldSchema: {
          groups: [
            {
              id: "debt_info",
              label: "Medical Debt Details",
              fields: [
                { id: "provider", label: "Medical Provider", type: "text", priority: "required", placeholder: "Hospital or doctor name" },
                { id: "accountNumber", label: "Account Number", type: "text", priority: "optional" },
                { id: "originalAmount", label: "Original Amount", type: "currency", priority: "optional" },
                { id: "currentBalance", label: "Current Balance", type: "currency", priority: "recommended" },
                { id: "paymentPlan", label: "Payment Plan", type: "toggle", priority: "optional", helpText: "Is there a payment plan set up?" },
                { id: "monthlyPayment", label: "Monthly Payment", type: "currency", priority: "optional" },
                { id: "expectedPayoffDate", label: "Expected Payoff Date", type: "date", priority: "optional" },
                { id: "contactPhone", label: "Billing Contact Phone", type: "phone", priority: "optional" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 8: Income & Employment
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Income & Employment",
    icon: "Briefcase",
    description: "Current employment, side income, Social Security, retirement income, and other sources.",
    categories: [
      {
        name: "Current Employment",
        type: "single",
        guidanceText: "Record your current primary employment details, including HR contacts and benefits information.",
        iconName: "Building",
        fieldSchema: {
          groups: [
            {
              id: "employer_info",
              label: "Employer Information",
              fields: [
                { id: "employer", label: "Employer Name", type: "text", priority: "required", placeholder: "Company name" },
                { id: "jobTitle", label: "Job Title", type: "text", priority: "required" },
                { id: "startDate", label: "Start Date", type: "date", priority: "recommended" },
                { id: "workAddress", label: "Work Address", type: "text", priority: "optional" },
              ],
            },
            {
              id: "compensation",
              label: "Compensation",
              fields: [
                { id: "salary", label: "Salary/Wage", type: "currency", priority: "recommended" },
                { id: "payFrequency", label: "Pay Frequency", type: "dropdown", priority: "recommended", options: ["Weekly", "Bi-weekly", "Semi-monthly", "Monthly", "Annual"] },
                { id: "directDeposit", label: "Direct Deposit Account", type: "text", priority: "optional", placeholder: "Which bank account receives pay?" },
              ],
            },
            {
              id: "contacts",
              label: "Contacts",
              fields: [
                { id: "supervisorName", label: "Supervisor Name", type: "text", priority: "optional" },
                { id: "supervisorPhone", label: "Supervisor Phone", type: "phone", priority: "optional" },
                { id: "hrContact", label: "HR Contact", type: "text", priority: "recommended", helpText: "Name, phone, or email of HR department" },
              ],
            },
            {
              id: "benefits",
              label: "Benefits",
              fields: [
                { id: "benefits", label: "Benefits Summary", type: "multiline", priority: "optional", helpText: "List key benefits: health insurance, 401k match, life insurance, stock options, etc." },
                { id: "benefitsPortal", label: "Benefits Portal", type: "url", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Side Income",
        type: "multi",
        guidanceText: "Freelance work, rental income, consulting, gig work, and other supplemental income sources.",
        iconName: "CircleDollarSign",
        fieldSchema: {
          groups: [
            {
              id: "income_info",
              label: "Income Details",
              fields: [
                { id: "source", label: "Income Source", type: "text", priority: "required", placeholder: "e.g., Freelance writing, Rental property" },
                { id: "type", label: "Income Type", type: "dropdown", priority: "recommended", options: ["Freelance/Contract", "Rental Income", "Consulting", "Gig Work", "Royalties", "Other"] },
                { id: "averageMonthly", label: "Average Monthly Income", type: "currency", priority: "recommended" },
                { id: "taxId", label: "Tax ID / EIN", type: "text", priority: "optional", helpText: "If this income has its own tax ID" },
                { id: "platform", label: "Platform/Client", type: "text", priority: "optional", placeholder: "e.g., Upwork, direct client" },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Social Security",
        type: "single",
        guidanceText: "Record your Social Security information and expected benefits.",
        iconName: "BadgeDollarSign",
        fieldSchema: {
          groups: [
            {
              id: "ss_info",
              label: "Social Security Information",
              fields: [
                { id: "ssNumber", label: "Social Security Number", type: "secureText", priority: "recommended" },
                { id: "estimatedMonthlyBenefit", label: "Estimated Monthly Benefit", type: "currency", priority: "optional", helpText: "Check ssa.gov for your estimate" },
                { id: "plannedStartAge", label: "Planned Start Age", type: "dropdown", priority: "optional", options: ["62", "63", "64", "65", "66", "67", "68", "69", "70"] },
                { id: "onlineAccountSetup", label: "SSA Online Account Created", type: "toggle", priority: "optional", helpText: "Have you created an account at ssa.gov?" },
                { id: "ssaUsername", label: "SSA Username", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Retirement Income",
        type: "multi",
        guidanceText: "Pensions, annuities, and other regular retirement income sources.",
        iconName: "Armchair",
        fieldSchema: {
          groups: [
            {
              id: "retirement_info",
              label: "Retirement Income Details",
              fields: [
                { id: "source", label: "Income Source", type: "text", priority: "required", placeholder: "e.g., State pension, company pension" },
                { id: "type", label: "Income Type", type: "dropdown", priority: "recommended", options: ["Pension", "Annuity", "Required Minimum Distribution", "Other"] },
                { id: "monthlyAmount", label: "Monthly Amount", type: "currency", priority: "recommended" },
                { id: "startDate", label: "Start Date", type: "date", priority: "optional" },
                { id: "beneficiary", label: "Survivor Beneficiary", type: "text", priority: "recommended", helpText: "Who receives this income if you pass?" },
                { id: "contactInfo", label: "Contact Information", type: "text", priority: "optional", helpText: "Phone or website for the pension administrator" },
              ],
            },
          ],
        },
      },
      {
        name: "Other Income",
        type: "multi",
        guidanceText: "Any other income sources not covered elsewhere — dividends, alimony, trusts, etc.",
        iconName: "Wallet",
        fieldSchema: {
          groups: [
            {
              id: "other_income",
              label: "Income Details",
              fields: [
                { id: "source", label: "Income Source", type: "text", priority: "required", placeholder: "e.g., Trust distribution, Alimony" },
                { id: "type", label: "Income Type", type: "dropdown", priority: "optional", options: ["Dividends", "Interest", "Alimony", "Trust Distribution", "Social Security Disability", "VA Benefits", "Other"] },
                { id: "amount", label: "Amount", type: "currency", priority: "recommended" },
                { id: "frequency", label: "Frequency", type: "dropdown", priority: "optional", options: ["Weekly", "Bi-weekly", "Monthly", "Quarterly", "Annually", "Irregular"] },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 9: Assets & Properties
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Assets & Properties",
    icon: "Gem",
    description: "Tangible assets of significant value and additional properties you own.",
    categories: [
      {
        name: "Tangible Assets",
        type: "multi",
        guidanceText: "Record significant physical assets like boats, RVs, valuable collections, etc. that are not covered in the Home Inventory section.",
        iconName: "Trophy",
        fieldSchema: {
          groups: [
            {
              id: "asset_info",
              label: "Asset Details",
              fields: [
                { id: "assetName", label: "Asset Name", type: "text", priority: "required", placeholder: "e.g., Sailboat, Art Collection, RV" },
                { id: "description", label: "Description", type: "multiline", priority: "recommended" },
                { id: "location", label: "Location", type: "text", priority: "recommended", placeholder: "Where is this asset kept?" },
                { id: "estimatedValue", label: "Estimated Value", type: "currency", priority: "recommended" },
                { id: "purchaseDate", label: "Purchase Date", type: "date", priority: "optional" },
                { id: "purchasePrice", label: "Purchase Price", type: "currency", priority: "optional" },
              ],
            },
            {
              id: "documentation",
              label: "Documentation & Insurance",
              fields: [
                { id: "ownershipDocs", label: "Ownership Documents Location", type: "text", priority: "optional", placeholder: "Where is the title/deed stored?" },
                { id: "serialOrId", label: "Serial/Identification Number", type: "text", priority: "optional" },
                { id: "insuranceInfo", label: "Insurance Information", type: "multiline", priority: "optional", helpText: "Policy number, company, and coverage details" },
              ],
            },
          ],
        },
      },
      {
        name: "Additional Properties",
        type: "multi",
        guidanceText: "Record any additional real estate you own — rental properties, vacation homes, land, etc.",
        iconName: "Building2",
        fieldSchema: {
          groups: [
            {
              id: "property_info",
              label: "Property Details",
              fields: [
                { id: "address", label: "Property Address", type: "text", priority: "required", placeholder: "Full address" },
                { id: "propertyType", label: "Property Type", type: "dropdown", priority: "recommended", options: ["Rental", "Vacation Home", "Land", "Commercial", "Farm", "Other"] },
                { id: "purchaseDate", label: "Purchase Date", type: "date", priority: "optional" },
                { id: "currentValue", label: "Current Estimated Value", type: "currency", priority: "recommended" },
              ],
            },
            {
              id: "financial",
              label: "Financial Details",
              fields: [
                { id: "mortgageBalance", label: "Mortgage Balance", type: "currency", priority: "optional" },
                { id: "mortgageLender", label: "Mortgage Lender", type: "text", priority: "optional" },
                { id: "rentalIncome", label: "Monthly Rental Income", type: "currency", priority: "optional" },
                { id: "propertyManager", label: "Property Manager", type: "text", priority: "optional", placeholder: "Name and phone" },
              ],
            },
            {
              id: "insurance",
              label: "Insurance",
              fields: [
                { id: "insuranceCompany", label: "Insurance Company", type: "text", priority: "recommended" },
                { id: "insurancePolicyNumber", label: "Policy Number", type: "text", priority: "optional" },
                { id: "insuranceInfo", label: "Additional Insurance Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 10: Your People
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Your People",
    icon: "Users",
    description: "Dependents, pets, and important people in your life.",
    categories: [
      {
        name: "Dependents",
        type: "multi",
        guidanceText: "Record information about each dependent — children, elderly parents, or anyone who relies on you.",
        iconName: "Baby",
        fieldSchema: {
          groups: [
            {
              id: "personal",
              label: "Personal Information",
              fields: [
                { id: "name", label: "Full Name", type: "text", priority: "required" },
                { id: "relationship", label: "Relationship", type: "dropdown", priority: "required", options: ["Child", "Stepchild", "Grandchild", "Parent", "Sibling", "Other"] },
                { id: "dateOfBirth", label: "Date of Birth", type: "date", priority: "required" },
                { id: "ssn", label: "Social Security Number", type: "secureText", priority: "optional" },
              ],
            },
            {
              id: "details",
              label: "Details",
              fields: [
                { id: "schoolOrEmployer", label: "School/Employer", type: "text", priority: "optional" },
                { id: "specialNeeds", label: "Special Needs", type: "multiline", priority: "optional", helpText: "Any special requirements or conditions" },
                { id: "medicalInfo", label: "Medical Information", type: "multiline", priority: "optional", helpText: "Allergies, medications, physician info" },
              ],
            },
            {
              id: "guardian",
              label: "Guardianship",
              fields: [
                { id: "guardianDesignated", label: "Designated Guardian", type: "text", priority: "recommended", helpText: "Who should care for this person if you cannot?" },
                { id: "guardianPhone", label: "Guardian Phone", type: "phone", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Pets",
        type: "multi",
        guidanceText: "Your furry, feathered, or scaly family members. Include care instructions so someone can step in.",
        iconName: "PawPrint",
        fieldSchema: {
          groups: [
            {
              id: "pet_info",
              label: "Pet Information",
              fields: [
                { id: "name", label: "Pet Name", type: "text", priority: "required" },
                { id: "species", label: "Species", type: "dropdown", priority: "required", options: ["Dog", "Cat", "Bird", "Fish", "Reptile", "Horse", "Other"] },
                { id: "breed", label: "Breed", type: "text", priority: "optional" },
                { id: "age", label: "Age/Date of Birth", type: "text", priority: "optional" },
                { id: "microchipNumber", label: "Microchip Number", type: "text", priority: "optional" },
              ],
            },
            {
              id: "care",
              label: "Care & Medical",
              fields: [
                { id: "vetName", label: "Veterinarian Name", type: "text", priority: "recommended" },
                { id: "vetPhone", label: "Vet Phone", type: "phone", priority: "recommended" },
                { id: "medications", label: "Medications", type: "multiline", priority: "optional" },
                { id: "insuranceInfo", label: "Pet Insurance Info", type: "text", priority: "optional" },
                { id: "careInstructions", label: "Care Instructions", type: "multiline", priority: "recommended", helpText: "Feeding schedule, exercise needs, special routines" },
              ],
            },
            {
              id: "emergency",
              label: "Emergency Care",
              fields: [
                { id: "emergencyCaretaker", label: "Emergency Caretaker", type: "text", priority: "recommended", helpText: "Who should take this pet if you cannot?" },
                { id: "caretakerPhone", label: "Caretaker Phone", type: "phone", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Friends & Social Circles",
        type: "multi",
        guidanceText: "Important friends, neighbors, and community contacts your family should know about.",
        iconName: "Heart",
        fieldSchema: {
          groups: [
            {
              id: "contact",
              label: "Contact Information",
              fields: [
                { id: "name", label: "Name", type: "text", priority: "required" },
                { id: "relationship", label: "Relationship/Context", type: "text", priority: "recommended", placeholder: "e.g., Best friend, neighbor, golf buddy" },
                { id: "phone", label: "Phone", type: "phone", priority: "recommended" },
                { id: "email", label: "Email", type: "email", priority: "optional" },
                { id: "address", label: "Address", type: "text", priority: "optional" },
                { id: "importanceNote", label: "Why They Matter", type: "multiline", priority: "optional", helpText: "Brief note about this relationship for your NOK" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 11: Your Life Story
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Your Life Story",
    icon: "BookOpen",
    description: "Education, career history, military service, ancestry, and sentimental items.",
    categories: [
      {
        name: "Education & Transcripts",
        type: "multi",
        guidanceText: "Record your educational history. Transcript locations can be important for surviving family members.",
        iconName: "GraduationCap",
        fieldSchema: {
          groups: [
            {
              id: "education",
              label: "Education Details",
              fields: [
                { id: "institution", label: "Institution Name", type: "text", priority: "required", placeholder: "School or university name" },
                { id: "degree", label: "Degree/Certificate", type: "text", priority: "recommended", placeholder: "e.g., B.S., M.A., High School Diploma" },
                { id: "fieldOfStudy", label: "Field of Study", type: "text", priority: "optional" },
                { id: "yearCompleted", label: "Year Completed", type: "text", priority: "recommended", placeholder: "e.g., 2005" },
                { id: "location", label: "Location", type: "text", priority: "optional" },
                { id: "transcriptLocation", label: "Transcript Location", type: "text", priority: "optional", helpText: "Where can transcripts be obtained?" },
              ],
            },
          ],
        },
      },
      {
        name: "Past Employment",
        type: "multi",
        guidanceText: "Career history — helpful for pension tracking, references, and life story documentation.",
        iconName: "BriefcaseBusiness",
        fieldSchema: {
          groups: [
            {
              id: "employment",
              label: "Employment Details",
              fields: [
                { id: "employer", label: "Employer", type: "text", priority: "required" },
                { id: "jobTitle", label: "Job Title", type: "text", priority: "required" },
                { id: "startDate", label: "Start Date", type: "date", priority: "recommended" },
                { id: "endDate", label: "End Date", type: "date", priority: "recommended" },
                { id: "reasonForLeaving", label: "Reason for Leaving", type: "text", priority: "optional" },
                { id: "notableAchievements", label: "Notable Achievements", type: "multiline", priority: "optional" },
                { id: "pensionEligible", label: "Pension Eligible", type: "toggle", priority: "optional", helpText: "Were you eligible for a pension here?" },
              ],
            },
          ],
        },
      },
      {
        name: "Military Service",
        type: "single",
        guidanceText: "If you served in the military, record your service details. This is critical for VA benefits.",
        iconName: "Shield",
        fieldSchema: {
          groups: [
            {
              id: "service",
              label: "Service Information",
              fields: [
                { id: "branch", label: "Branch of Service", type: "dropdown", priority: "required", options: ["Army", "Navy", "Air Force", "Marines", "Coast Guard", "Space Force", "National Guard", "Reserve", "Other"] },
                { id: "rank", label: "Rank at Discharge", type: "text", priority: "recommended" },
                { id: "serviceNumber", label: "Service Number", type: "text", priority: "recommended" },
                { id: "enlistmentDate", label: "Enlistment Date", type: "date", priority: "recommended" },
                { id: "dischargeDate", label: "Discharge Date", type: "date", priority: "recommended" },
                { id: "dischargeType", label: "Discharge Type", type: "dropdown", priority: "recommended", options: ["Honorable", "General", "Other Than Honorable", "Bad Conduct", "Dishonorable", "Other"] },
              ],
            },
            {
              id: "va_benefits",
              label: "VA & Benefits",
              fields: [
                { id: "vaInfo", label: "VA Information", type: "multiline", priority: "optional", helpText: "VA hospital, claim numbers, disability rating" },
                { id: "benefitsInfo", label: "Benefits Information", type: "multiline", priority: "optional", helpText: "GI Bill, pension, disability compensation, burial benefits" },
                { id: "dd214Location", label: "DD-214 Location", type: "text", priority: "recommended", helpText: "Where is your discharge paperwork stored?" },
              ],
            },
          ],
        },
      },
      {
        name: "Ancestry",
        type: "single",
        guidanceText: "Family history, heritage, and ancestry information you want to preserve.",
        iconName: "TreePine",
        fieldSchema: {
          groups: [
            {
              id: "ancestry",
              label: "Ancestry & Heritage",
              fields: [
                { id: "notes", label: "Family History Notes", type: "multiline", priority: "optional", helpText: "Capture stories, heritage, and family connections" },
                { id: "importantDocuments", label: "Important Documents", type: "multiline", priority: "optional", helpText: "Birth certificates, immigration papers, family bibles, etc." },
                { id: "familyTreeInfo", label: "Family Tree Information", type: "multiline", priority: "optional", helpText: "Link to family tree services or notes on lineage" },
                { id: "dnaTestingService", label: "DNA Testing Service", type: "text", priority: "optional", placeholder: "e.g., 23andMe, AncestryDNA" },
              ],
            },
          ],
        },
      },
      {
        name: "Sentimental Items",
        type: "multi",
        guidanceText: "Items with emotional or historical significance — and who you want to have them.",
        iconName: "Heart",
        fieldSchema: {
          groups: [
            {
              id: "item",
              label: "Sentimental Item",
              fields: [
                { id: "itemDescription", label: "Item Description", type: "text", priority: "required", placeholder: "e.g., Grandmother's wedding ring" },
                { id: "location", label: "Current Location", type: "text", priority: "recommended" },
                { id: "intendedRecipient", label: "Intended Recipient", type: "text", priority: "recommended", helpText: "Who should receive this item?" },
                { id: "storyOrSignificance", label: "Story/Significance", type: "multiline", priority: "optional", helpText: "Why is this item meaningful?" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 12: Health & Medical
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Health & Medical",
    icon: "HeartPulse",
    description: "Medical information, providers, history, and Medicare/Medicaid details.",
    categories: [
      {
        name: "Current Medical",
        type: "single",
        guidanceText: "Your current health status — allergies, medications, conditions, and preferences. Critical in an emergency.",
        iconName: "Activity",
        fieldSchema: {
          groups: [
            {
              id: "general",
              label: "General Health",
              fields: [
                { id: "primaryPhysician", label: "Primary Physician", type: "text", priority: "required", placeholder: "Doctor's name" },
                { id: "primaryPhysicianPhone", label: "Physician Phone", type: "phone", priority: "recommended" },
                { id: "bloodType", label: "Blood Type", type: "dropdown", priority: "recommended", options: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Unknown"] },
                { id: "height", label: "Height", type: "text", priority: "optional" },
                { id: "weight", label: "Weight", type: "text", priority: "optional" },
              ],
            },
            {
              id: "conditions",
              label: "Conditions & Medications",
              fields: [
                { id: "allergies", label: "Allergies", type: "multiline", priority: "required", helpText: "Drug allergies, food allergies, environmental allergies" },
                { id: "currentMedications", label: "Current Medications", type: "multiline", priority: "required", helpText: "Name, dosage, frequency, prescribing doctor" },
                { id: "ongoingConditions", label: "Ongoing Conditions", type: "multiline", priority: "recommended", helpText: "Diabetes, hypertension, etc." },
                { id: "medicalDevices", label: "Medical Devices", type: "multiline", priority: "optional", helpText: "Pacemaker, insulin pump, CPAP, hearing aids, etc." },
              ],
            },
            {
              id: "directives",
              label: "Emergency Preferences",
              fields: [
                { id: "dnrStatus", label: "DNR Status", type: "dropdown", priority: "optional", options: ["Full Code", "DNR", "DNR/DNI", "Not Yet Decided", "See Legal Documents"] },
                { id: "organDonor", label: "Organ Donor", type: "toggle", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Past Medical",
        type: "multi",
        guidanceText: "Significant past medical events — surgeries, hospitalizations, major diagnoses.",
        iconName: "ClipboardList",
        fieldSchema: {
          groups: [
            {
              id: "history",
              label: "Medical Event",
              fields: [
                { id: "condition", label: "Condition/Procedure", type: "text", priority: "required", placeholder: "e.g., Knee replacement, Appendectomy" },
                { id: "dateOfDiagnosis", label: "Date", type: "date", priority: "recommended" },
                { id: "treatment", label: "Treatment", type: "multiline", priority: "optional" },
                { id: "hospital", label: "Hospital/Facility", type: "text", priority: "optional" },
                { id: "surgeon", label: "Surgeon/Doctor", type: "text", priority: "optional" },
                { id: "outcome", label: "Outcome", type: "text", priority: "optional" },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Healthcare Providers",
        type: "multi",
        guidanceText: "All your healthcare providers — specialists, dentists, therapists, pharmacies.",
        iconName: "Stethoscope",
        fieldSchema: {
          groups: [
            {
              id: "provider",
              label: "Provider Details",
              fields: [
                { id: "providerName", label: "Provider Name", type: "text", priority: "required" },
                { id: "specialty", label: "Specialty", type: "dropdown", priority: "recommended", options: ["Primary Care", "Cardiology", "Dermatology", "Dentist", "Endocrinology", "ENT", "Gastroenterology", "Neurology", "OB/GYN", "Oncology", "Ophthalmology", "Orthopedics", "Physical Therapy", "Podiatry", "Psychiatry", "Psychology", "Pulmonology", "Rheumatology", "Urology", "Pharmacy", "Other"] },
                { id: "phone", label: "Phone", type: "phone", priority: "required" },
                { id: "address", label: "Address", type: "text", priority: "optional" },
                { id: "patientPortalLogin", label: "Patient Portal Login", type: "text", priority: "optional" },
                { id: "insuranceUsed", label: "Insurance Used", type: "text", priority: "optional", placeholder: "Which insurance do you use here?" },
              ],
            },
          ],
        },
      },
      {
        name: "Medicare/Medicaid",
        type: "single",
        guidanceText: "Government health insurance details — Medicare, Medicaid, or both.",
        iconName: "ShieldPlus",
        fieldSchema: {
          groups: [
            {
              id: "medicare",
              label: "Medicare",
              fields: [
                { id: "medicareNumber", label: "Medicare Number", type: "secureText", priority: "recommended" },
                { id: "partAStartDate", label: "Part A Start Date", type: "date", priority: "optional" },
                { id: "partBStartDate", label: "Part B Start Date", type: "date", priority: "optional" },
                { id: "partDPlan", label: "Part D Plan", type: "text", priority: "optional", placeholder: "Prescription drug plan name" },
                { id: "supplementalPlan", label: "Supplemental/Medigap Plan", type: "text", priority: "optional" },
              ],
            },
            {
              id: "medicaid",
              label: "Medicaid",
              fields: [
                { id: "medicaidId", label: "Medicaid ID", type: "secureText", priority: "optional" },
                { id: "medicaidState", label: "Medicaid State", type: "text", priority: "optional" },
                { id: "managedCarePlan", label: "Managed Care Plan", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 13: Digital Life
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Digital Life",
    icon: "Globe",
    description: "Online accounts, subscriptions, social media, and community memberships.",
    categories: [
      {
        name: "Communities & Organizations",
        type: "multi",
        guidanceText: "Churches, clubs, professional associations, volunteer organizations, and community groups.",
        iconName: "Users2",
        fieldSchema: {
          groups: [
            {
              id: "org_info",
              label: "Organization Details",
              fields: [
                { id: "organizationName", label: "Organization Name", type: "text", priority: "required", placeholder: "e.g., Rotary Club, St. Mary's Church" },
                { id: "membershipType", label: "Membership Type", type: "text", priority: "optional", placeholder: "e.g., Active member, Board member" },
                { id: "membershipNumber", label: "Membership Number", type: "text", priority: "optional" },
                { id: "duesAmount", label: "Dues Amount", type: "currency", priority: "optional" },
                { id: "duesFrequency", label: "Dues Frequency", type: "dropdown", priority: "optional", options: ["Monthly", "Quarterly", "Annually", "None"] },
                { id: "contactInfo", label: "Contact Information", type: "text", priority: "optional" },
                { id: "websiteLogin", label: "Website/Login", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Subscriptions & Memberships",
        type: "multi",
        guidanceText: "Streaming services, software subscriptions, gym memberships, and recurring services.",
        iconName: "RefreshCw",
        fieldSchema: {
          groups: [
            {
              id: "subscription",
              label: "Subscription Details",
              fields: [
                { id: "serviceName", label: "Service Name", type: "text", priority: "required", placeholder: "e.g., Netflix, Spotify, Adobe" },
                { id: "type", label: "Type", type: "dropdown", priority: "optional", options: ["Streaming", "Software", "Gym/Fitness", "News/Magazine", "Cloud Storage", "Gaming", "Food Delivery", "Other"] },
                { id: "cost", label: "Cost", type: "currency", priority: "recommended" },
                { id: "billingFrequency", label: "Billing Frequency", type: "dropdown", priority: "recommended", options: ["Monthly", "Quarterly", "Annually", "Lifetime"] },
                { id: "accountEmail", label: "Account Email", type: "email", priority: "optional" },
                { id: "linkedPayment", label: "Payment Method", type: "text", priority: "optional", placeholder: "Which card/account pays for this?" },
                { id: "cancelInstructions", label: "Cancel Instructions", type: "multiline", priority: "optional", helpText: "How to cancel this subscription" },
              ],
            },
          ],
        },
      },
      {
        name: "Social Media",
        type: "multi",
        guidanceText: "Record your social media accounts and what should happen to them if something happens to you.",
        iconName: "Share2",
        fieldSchema: {
          groups: [
            {
              id: "account_info",
              label: "Account Information",
              fields: [
                { id: "platform", label: "Platform", type: "dropdown", priority: "required", options: ["Facebook", "Instagram", "Twitter/X", "LinkedIn", "TikTok", "YouTube", "Pinterest", "Reddit", "Snapchat", "Other"] },
                { id: "username", label: "Username/Handle", type: "text", priority: "required" },
                { id: "email", label: "Account Email", type: "email", priority: "optional" },
                { id: "password", label: "Password", type: "secureText", priority: "optional", helpText: "Consider using a password manager reference" },
                { id: "twoFactorSetup", label: "Two-Factor Authentication", type: "toggle", priority: "optional" },
              ],
            },
            {
              id: "posthumous",
              label: "After-Death Instructions",
              fields: [
                { id: "memorialization", label: "Memorialization Preference", type: "dropdown", priority: "optional", options: ["Memorialize Account", "Delete Account", "Legacy Contact Manages", "No Preference"] },
                { id: "legacyContact", label: "Legacy Contact", type: "text", priority: "optional", helpText: "Person designated to manage this account" },
                { id: "deathInstructions", label: "Specific Instructions", type: "multiline", priority: "optional", helpText: "Any specific wishes for this account" },
              ],
            },
          ],
        },
      },
      {
        name: "Other Online Accounts",
        type: "multi",
        guidanceText: "Email, cloud storage, shopping accounts, and other important online accounts.",
        iconName: "AtSign",
        fieldSchema: {
          groups: [
            {
              id: "account",
              label: "Account Details",
              fields: [
                { id: "serviceName", label: "Service Name", type: "text", priority: "required", placeholder: "e.g., Gmail, iCloud, Amazon" },
                { id: "website", label: "Website", type: "url", priority: "optional" },
                { id: "username", label: "Username", type: "text", priority: "recommended" },
                { id: "password", label: "Password", type: "secureText", priority: "optional", helpText: "Consider using a password manager reference" },
                { id: "recoveryEmail", label: "Recovery Email", type: "email", priority: "optional" },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional", helpText: "What is this account used for? Any important data stored here?" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 14: Legal & Taxes
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Legal & Taxes",
    icon: "Scale",
    description: "Tax records, legal documents, wills, trusts, powers of attorney, and directives.",
    categories: [
      {
        name: "Tax Records",
        type: "multi",
        guidanceText: "Record tax filing history. Your next of kin may need access to recent returns.",
        iconName: "Receipt",
        fieldSchema: {
          groups: [
            {
              id: "tax_info",
              label: "Tax Year Record",
              fields: [
                { id: "taxYear", label: "Tax Year", type: "text", priority: "required", placeholder: "e.g., 2025" },
                { id: "preparer", label: "Tax Preparer", type: "text", priority: "recommended", placeholder: "CPA or service name" },
                { id: "preparerPhone", label: "Preparer Phone", type: "phone", priority: "optional" },
                { id: "filingStatus", label: "Filing Status", type: "dropdown", priority: "recommended", options: ["Single", "Married Filing Jointly", "Married Filing Separately", "Head of Household", "Qualifying Surviving Spouse"] },
                { id: "agiAmount", label: "Adjusted Gross Income", type: "currency", priority: "optional" },
                { id: "refundOrOwed", label: "Refund/Owed", type: "text", priority: "optional", placeholder: "e.g., Refund $2,500 or Owed $500" },
                { id: "storageLocation", label: "Return Storage Location", type: "text", priority: "recommended", helpText: "Where is the physical or digital copy?" },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Legal Documents",
        type: "multi",
        guidanceText: "Track important legal documents, their locations, and the attorneys involved.",
        iconName: "FileText",
        fieldSchema: {
          groups: [
            {
              id: "document",
              label: "Document Details",
              fields: [
                { id: "documentType", label: "Document Type", type: "dropdown", priority: "required", options: ["Birth Certificate", "Marriage Certificate", "Divorce Decree", "Deed", "Title", "Contract", "Court Order", "Immigration Papers", "Naturalization Certificate", "Other"] },
                { id: "dateCreated", label: "Date Created/Issued", type: "date", priority: "optional" },
                { id: "attorney", label: "Attorney", type: "text", priority: "optional" },
                { id: "attorneyPhone", label: "Attorney Phone", type: "phone", priority: "optional" },
                { id: "storageLocation", label: "Physical Storage Location", type: "text", priority: "required", placeholder: "e.g., Safe deposit box, home safe, filing cabinet" },
                { id: "digitalCopyLocation", label: "Digital Copy Location", type: "text", priority: "optional" },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Will/Trust",
        type: "single",
        guidanceText: "Details about your will and/or trust — one of the most critical documents for your estate.",
        iconName: "ScrollText",
        fieldSchema: {
          groups: [
            {
              id: "will",
              label: "Will",
              fields: [
                { id: "hasWill", label: "Has a Will", type: "toggle", priority: "required" },
                { id: "willDate", label: "Will Date", type: "date", priority: "recommended" },
                { id: "willLocation", label: "Will Location", type: "text", priority: "required", helpText: "Physical location where the will is stored" },
                { id: "attorney", label: "Estate Attorney", type: "text", priority: "recommended" },
                { id: "attorneyPhone", label: "Attorney Phone", type: "phone", priority: "optional" },
                { id: "executorName", label: "Executor Name", type: "text", priority: "required", helpText: "Person designated to carry out the will" },
                { id: "executorPhone", label: "Executor Phone", type: "phone", priority: "optional" },
              ],
            },
            {
              id: "trust",
              label: "Trust",
              fields: [
                { id: "hasTrust", label: "Has a Trust", type: "toggle", priority: "optional" },
                { id: "trustType", label: "Trust Type", type: "dropdown", priority: "optional", options: ["Revocable Living Trust", "Irrevocable Trust", "Testamentary Trust", "Special Needs Trust", "Charitable Trust", "Other"] },
                { id: "trustee", label: "Trustee", type: "text", priority: "optional" },
                { id: "successor", label: "Successor Trustee", type: "text", priority: "optional" },
                { id: "trustLocation", label: "Trust Document Location", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Medical Directives",
        type: "single",
        guidanceText: "Advance directives, living will, healthcare proxy — these guide medical decisions if you cannot speak for yourself.",
        iconName: "HeartHandshake",
        fieldSchema: {
          groups: [
            {
              id: "directives",
              label: "Advance Directives",
              fields: [
                { id: "hasAdvanceDirective", label: "Has Advance Directive", type: "toggle", priority: "required" },
                { id: "directiveLocation", label: "Directive Location", type: "text", priority: "required", helpText: "Where is the document stored?" },
                { id: "directiveDate", label: "Directive Date", type: "date", priority: "optional" },
              ],
            },
            {
              id: "proxy",
              label: "Healthcare Proxy",
              fields: [
                { id: "healthcareProxy", label: "Healthcare Proxy", type: "text", priority: "required", helpText: "Person authorized to make medical decisions on your behalf" },
                { id: "proxyPhone", label: "Proxy Phone", type: "phone", priority: "recommended" },
                { id: "alternateProxy", label: "Alternate Proxy", type: "text", priority: "optional" },
              ],
            },
            {
              id: "preferences",
              label: "Specific Preferences",
              fields: [
                { id: "dnrStatus", label: "DNR Status", type: "dropdown", priority: "recommended", options: ["Full Code", "DNR", "DNR/DNI", "Not Yet Decided"] },
                { id: "organDonor", label: "Organ Donor", type: "toggle", priority: "optional" },
                { id: "specificWishes", label: "Specific Wishes", type: "multiline", priority: "optional", helpText: "Any specific medical treatment preferences" },
              ],
            },
          ],
        },
      },
      {
        name: "Financial POA",
        type: "single",
        guidanceText: "Financial Power of Attorney — who can manage your finances if you're unable to.",
        iconName: "Stamp",
        fieldSchema: {
          groups: [
            {
              id: "poa",
              label: "Power of Attorney",
              fields: [
                { id: "hasPOA", label: "Has Financial POA", type: "toggle", priority: "required" },
                { id: "poaAgent", label: "POA Agent", type: "text", priority: "required", helpText: "Person designated as your financial power of attorney" },
                { id: "poaAgentPhone", label: "Agent Phone", type: "phone", priority: "recommended" },
                { id: "poaAlternate", label: "Alternate Agent", type: "text", priority: "optional" },
                { id: "poaScope", label: "POA Scope", type: "dropdown", priority: "optional", options: ["General (broad authority)", "Limited (specific transactions)", "Springing (upon incapacitation)"] },
                { id: "documentLocation", label: "Document Location", type: "text", priority: "required" },
                { id: "effectiveDate", label: "Effective Date", type: "date", priority: "optional" },
                { id: "attorney", label: "Attorney Who Prepared", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Guardianship",
        type: "single",
        guidanceText: "If you have minor children or dependents, designate who should care for them.",
        iconName: "UserCheck",
        fieldSchema: {
          groups: [
            {
              id: "children",
              label: "Minor Children Guardianship",
              fields: [
                { id: "hasMinorChildren", label: "Has Minor Children", type: "toggle", priority: "required" },
                { id: "designatedGuardian", label: "Designated Guardian", type: "text", priority: "required", helpText: "Who should care for your children?" },
                { id: "guardianPhone", label: "Guardian Phone", type: "phone", priority: "recommended" },
                { id: "alternateGuardian", label: "Alternate Guardian", type: "text", priority: "optional" },
              ],
            },
            {
              id: "pets",
              label: "Pet Guardianship",
              fields: [
                { id: "petGuardian", label: "Pet Guardian", type: "text", priority: "optional", helpText: "Who should care for your pets?" },
                { id: "petGuardianPhone", label: "Pet Guardian Phone", type: "phone", priority: "optional" },
              ],
            },
            {
              id: "documents",
              label: "Documentation",
              fields: [
                { id: "documentLocation", label: "Guardianship Document Location", type: "text", priority: "recommended" },
                { id: "attorney", label: "Attorney", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 15: End of Life
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "End of Life",
    icon: "Sunset",
    description: "Final wishes — disposition, memorial service, pre-arrangements, and personal letters.",
    categories: [
      {
        name: "Disposition & Funeral Wishes",
        type: "single",
        guidanceText: "Your preferences for body disposition and funeral arrangements.",
        iconName: "Flower2",
        fieldSchema: {
          groups: [
            {
              id: "disposition",
              label: "Disposition Preferences",
              fields: [
                { id: "preference", label: "Disposition Preference", type: "dropdown", priority: "required", options: ["Burial", "Cremation", "Body Donation", "Green Burial", "Aquamation", "Other", "No Preference"] },
                { id: "specificWishes", label: "Specific Wishes", type: "multiline", priority: "optional", helpText: "Details about your preferences" },
                { id: "locationPreference", label: "Location Preference", type: "text", priority: "optional", placeholder: "Cemetery, location for scattering, etc." },
              ],
            },
            {
              id: "details",
              label: "Funeral Details",
              fields: [
                { id: "clothing", label: "Clothing Preference", type: "text", priority: "optional", helpText: "What you would like to be dressed in" },
                { id: "casketOrUrn", label: "Casket/Urn Preference", type: "text", priority: "optional" },
                { id: "viewingPreference", label: "Viewing/Visitation", type: "dropdown", priority: "optional", options: ["Open Casket", "Closed Casket", "No Viewing", "Private Family Only", "No Preference"] },
                { id: "additionalWishes", label: "Additional Wishes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Memorial Service Preferences",
        type: "single",
        guidanceText: "How you would like to be remembered — service type, music, readings, and more.",
        iconName: "Candle",
        fieldSchema: {
          groups: [
            {
              id: "service",
              label: "Service Preferences",
              fields: [
                { id: "serviceType", label: "Service Type", type: "dropdown", priority: "recommended", options: ["Religious Service", "Celebration of Life", "Military Honors", "Private Family Gathering", "No Service", "Other"] },
                { id: "location", label: "Preferred Location", type: "text", priority: "optional" },
                { id: "religiousPreferences", label: "Religious/Spiritual Preferences", type: "multiline", priority: "optional" },
                { id: "officiant", label: "Preferred Officiant", type: "text", priority: "optional" },
              ],
            },
            {
              id: "personal_touches",
              label: "Personal Touches",
              fields: [
                { id: "musicSelections", label: "Music Selections", type: "multiline", priority: "optional", helpText: "Songs or hymns you'd like played" },
                { id: "readings", label: "Readings/Poems", type: "multiline", priority: "optional" },
                { id: "speakers", label: "Speakers", type: "multiline", priority: "optional", helpText: "People you'd like to speak" },
                { id: "flowers", label: "Flower Preferences", type: "text", priority: "optional" },
                { id: "donations", label: "Charitable Donations In Lieu Of", type: "text", priority: "optional", helpText: "Charity to receive donations instead of flowers" },
              ],
            },
          ],
        },
      },
      {
        name: "Pre-Arrangements",
        type: "single",
        guidanceText: "If you have pre-paid or pre-planned funeral arrangements, record the details here.",
        iconName: "FileCheck",
        fieldSchema: {
          groups: [
            {
              id: "arrangements",
              label: "Pre-Arrangement Details",
              fields: [
                { id: "funeralHome", label: "Funeral Home", type: "text", priority: "required", placeholder: "Name of funeral home" },
                { id: "contactInfo", label: "Contact Information", type: "phone", priority: "recommended" },
                { id: "address", label: "Address", type: "text", priority: "optional" },
                { id: "contractNumber", label: "Contract Number", type: "text", priority: "recommended" },
                { id: "prepaidAmount", label: "Prepaid Amount", type: "currency", priority: "optional" },
                { id: "planDetails", label: "Plan Details", type: "multiline", priority: "optional", helpText: "What is covered under the pre-arrangement?" },
                { id: "documentLocation", label: "Contract Location", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Letters & Recordings",
        type: "multi",
        guidanceText: "Personal messages to loved ones — letters, videos, or audio recordings to be shared after you're gone.",
        iconName: "PenLine",
        fieldSchema: {
          groups: [
            {
              id: "message",
              label: "Message Details",
              fields: [
                { id: "recipientName", label: "Recipient Name", type: "text", priority: "required" },
                { id: "type", label: "Message Type", type: "dropdown", priority: "required", options: ["Letter", "Video", "Audio", "Other"] },
                { id: "content", label: "Message Content", type: "multiline", priority: "optional", helpText: "Write your message here, or describe where the recording is stored" },
                { id: "storageLocation", label: "Storage Location", type: "text", priority: "recommended", helpText: "Where is this letter/recording stored?" },
                { id: "deliveryInstructions", label: "Delivery Instructions", type: "multiline", priority: "optional", helpText: "When and how should this be delivered?" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 16: Protected Documents
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "Protected Documents",
    icon: "FolderLock",
    description: "Track important physical documents and access keys/codes for security systems.",
    categories: [
      {
        name: "Document Checklist",
        type: "single",
        guidanceText: "Track whether you have each critical document and where it's stored.",
        iconName: "CheckSquare",
        fieldSchema: {
          groups: [
            {
              id: "identity_docs",
              label: "Identity Documents",
              fields: [
                { id: "birthCertificate", label: "Birth Certificate", type: "toggle", priority: "required" },
                { id: "birthCertificateLocation", label: "Birth Certificate Location", type: "text", priority: "recommended" },
                { id: "socialSecurityCard", label: "Social Security Card", type: "toggle", priority: "required" },
                { id: "socialSecurityCardLocation", label: "SS Card Location", type: "text", priority: "recommended" },
                { id: "passport", label: "Passport", type: "toggle", priority: "recommended" },
                { id: "passportLocation", label: "Passport Location", type: "text", priority: "optional" },
                { id: "driversLicense", label: "Driver's License", type: "toggle", priority: "recommended" },
                { id: "driversLicenseLocation", label: "License Location", type: "text", priority: "optional" },
              ],
            },
            {
              id: "family_docs",
              label: "Family Documents",
              fields: [
                { id: "marriageCertificate", label: "Marriage Certificate", type: "toggle", priority: "optional" },
                { id: "marriageCertificateLocation", label: "Marriage Cert Location", type: "text", priority: "optional" },
                { id: "divorcePapers", label: "Divorce Papers", type: "toggle", priority: "optional" },
                { id: "divorcePapersLocation", label: "Divorce Papers Location", type: "text", priority: "optional" },
              ],
            },
            {
              id: "legal_docs",
              label: "Legal & Financial Documents",
              fields: [
                { id: "militaryDischarge", label: "Military Discharge (DD-214)", type: "toggle", priority: "optional" },
                { id: "militaryDischargeLocation", label: "DD-214 Location", type: "text", priority: "optional" },
                { id: "deedOrTitle", label: "Property Deed/Title", type: "toggle", priority: "optional" },
                { id: "deedOrTitleLocation", label: "Deed/Title Location", type: "text", priority: "optional" },
                { id: "vehicleTitles", label: "Vehicle Titles", type: "toggle", priority: "optional" },
                { id: "vehicleTitlesLocation", label: "Vehicle Titles Location", type: "text", priority: "optional" },
                { id: "insurancePolicies", label: "Insurance Policies", type: "toggle", priority: "optional" },
                { id: "insurancePoliciesLocation", label: "Insurance Policies Location", type: "text", priority: "optional" },
                { id: "willOrTrust", label: "Will/Trust", type: "toggle", priority: "recommended" },
                { id: "willOrTrustLocation", label: "Will/Trust Location", type: "text", priority: "recommended" },
                { id: "powerOfAttorney", label: "Power of Attorney", type: "toggle", priority: "optional" },
                { id: "powerOfAttorneyLocation", label: "POA Location", type: "text", priority: "optional" },
                { id: "advanceDirective", label: "Advance Directive", type: "toggle", priority: "optional" },
                { id: "advanceDirectiveLocation", label: "Advance Directive Location", type: "text", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Key System Log",
        type: "multi",
        guidanceText: "Physical keys, safe combinations, access codes, and security system information.",
        iconName: "Key",
        fieldSchema: {
          groups: [
            {
              id: "key_info",
              label: "Key/Access Details",
              fields: [
                { id: "keyDescription", label: "Key/System Description", type: "text", priority: "required", placeholder: "e.g., Home front door, Office, Safe deposit box" },
                { id: "location", label: "Key Location", type: "text", priority: "required", placeholder: "Where is this key kept?" },
                { id: "whoHasCopy", label: "Who Has a Copy", type: "text", priority: "recommended" },
                { id: "combination", label: "Combination/Code", type: "secureText", priority: "optional" },
              ],
            },
            {
              id: "security",
              label: "Security System",
              fields: [
                { id: "locksmithInfo", label: "Locksmith Information", type: "text", priority: "optional" },
                { id: "securityCompany", label: "Security System Company", type: "text", priority: "optional" },
                { id: "securitySystemInfo", label: "Security System Details", type: "multiline", priority: "optional", helpText: "Panel location, master code, monitoring details" },
              ],
            },
          ],
        },
      },
    ],
  },

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 17: For Your Next of Kin
  // ═══════════════════════════════════════════════════════════════════════════
  {
    name: "For Your Next of Kin",
    icon: "HeartHandshake",
    description: "Guidance and checklists for your next of kin — what to do first, who to contact, and step-by-step instructions.",
    categories: [
      {
        name: "NOK Action Guide",
        type: "single",
        guidanceText: "This section contains your instructions for your next of kin — who to call first, where to find important items, and urgent steps to take.",
        iconName: "BookOpen",
        fieldSchema: {
          groups: [
            {
              id: "immediate",
              label: "Immediate Actions",
              fields: [
                { id: "immediateContacts", label: "Immediate Contacts", type: "multiline", priority: "required", helpText: "Who should be contacted first? List names and phone numbers in priority order." },
                { id: "importantLocations", label: "Important Locations", type: "multiline", priority: "required", helpText: "Where are keys, documents, safe, etc.? Think about what someone needs to find first." },
                { id: "urgentInstructions", label: "Urgent Instructions", type: "multiline", priority: "required", helpText: "Any time-sensitive actions — bills due, pets to feed, perishable responsibilities." },
              ],
            },
            {
              id: "guidance",
              label: "General Guidance",
              fields: [
                { id: "financialSteps", label: "Financial First Steps", type: "multiline", priority: "optional", helpText: "Which accounts to notify, how to access funds for immediate expenses" },
                { id: "legalSteps", label: "Legal First Steps", type: "multiline", priority: "optional", helpText: "Contact the estate attorney, locate the will, file death certificate" },
                { id: "personalWishes", label: "Personal Wishes & Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Immediate Steps Checklist",
        type: "multi",
        guidanceText: "A checklist of immediate steps for your next of kin to follow. These become interactive checkboxes in executor mode.",
        iconName: "ListChecks",
        fieldSchema: {
          groups: [
            {
              id: "step",
              label: "Checklist Step",
              fields: [
                { id: "stepDescription", label: "Step Description", type: "text", priority: "required", placeholder: "e.g., Call employer HR department" },
                { id: "priority", label: "Priority", type: "dropdown", priority: "recommended", options: ["Immediate (Day 1)", "Within First Week", "Within First Month", "Within 3 Months", "Within 6 Months"] },
                { id: "details", label: "Additional Details", type: "multiline", priority: "optional", helpText: "Phone numbers, reference numbers, or specific instructions" },
                { id: "isCompleted", label: "Completed", type: "toggle", priority: "optional" },
                { id: "completedDate", label: "Date Completed", type: "date", priority: "optional" },
                { id: "notes", label: "Notes", type: "multiline", priority: "optional" },
              ],
            },
          ],
        },
      },
      {
        name: "Section NokLists",
        type: "single",
        guidanceText: "Auto-generated checklists based on entries across all sections. In executor mode, these become interactive task lists to track progress through the estate.",
        iconName: "ClipboardCheck",
        fieldSchema: {
          groups: [
            {
              id: "noklist_info",
              label: "NokList Overview",
              fields: [
                { id: "overview", label: "Overview", type: "multiline", priority: "optional", helpText: "This section auto-generates checklists from your vault entries. Each entry across all sections becomes a task for your next of kin to review and act on." },
                { id: "customInstructions", label: "Custom Instructions", type: "multiline", priority: "optional", helpText: "Any additional instructions for working through the NokList" },
              ],
            },
          ],
        },
      },
    ],
  },
];

export function seedVaultData(vaultId: number): void {
  let sectionSortOrder = 0;

  for (const sectionDef of SECTIONS) {
    sectionSortOrder++;

    const section = db
      .insert(sections)
      .values({
        vaultId,
        name: sectionDef.name,
        icon: sectionDef.icon,
        sortOrder: sectionSortOrder,
        description: sectionDef.description,
        isVisible: 1,
      })
      .returning()
      .get();

    let categorySortOrder = 0;

    for (const catDef of sectionDef.categories) {
      categorySortOrder++;

      db.insert(categories)
        .values({
          sectionId: section.id,
          name: catDef.name,
          type: catDef.type,
          guidanceText: catDef.guidanceText,
          iconName: catDef.iconName,
          sortOrder: categorySortOrder,
          fieldSchema: JSON.stringify(catDef.fieldSchema),
        })
        .run();
    }
  }
}
