A blockchain-based solution for tracking minerals from mine to export, ensuring ethical sourcing and complete supply chain transparency.

## 🎯 Problem Solved

Traditional supply chains lack transparency, making it difficult to verify the origin and ethical sourcing of steel, iron, or tin products. This system provides:

- 📍 GPS and IoT tracking for shipments
- 🔒 Immutable transaction history
- 🏆 Digital "ethical sourcing" certificates
- ✅ Complete supply chain verification

## 🏗️ Architecture

The system tracks materials through four key stages:
1. **🏔️ Mine** - Initial material registration
2. **🚚 Transport** - Material transportation
3. **🏭 Refinery** - Processing and refining
4. **📦 Export** - Final export and certification

## 🚀 Features

### Core Functionality
- ✅ **Participant Registration** - Verify companies in the supply chain
- 📋 **Material Registration** - Track materials from source
- 📦 **Batch Material Registration** - Register multiple materials in a single transaction
- � **Material Transfers** - Secure handoffs between stages
- 📍 **GPS Tracking** - Real-time location data
- 🔍 **IoT Integration** - Sensor data for verification
- 📜 **Ethical Certificates** - Digital proof of ethical sourcing

### Security & Verification
- 🛡️ Role-based access control
- 🔐 Cryptographic verification hashes
- 📊 Complete audit trail
- ⚡ Smart contract validation

## 📖 Usage Instructions

### 1. Register Participants (Contract Owner Only)

```clarity
(contract-call? .mining-supply-chain register-participant 
    'SP1234... 
    "mine" 
    "ABC Mining Co" 
    "Ghana")
```

### 2. Register Material (Mine Role Required)

```clarity
(contract-call? .mining-supply-chain register-material 
    "iron-ore" 
    "ABC Mine Site A" 
    u1000 
    "5.6037" 
    "-0.1870" 
    "IOT-SENSOR-001")
```

### 3. Transfer Material Between Stages

```clarity
(contract-call? .mining-supply-chain transfer-material 
    u1 
    'SP5678... 
    "transport" 
    "5.6040" 
    "-0.1875" 
    "hash12345...")
```

### 4. Confirm Receipt

```clarity
(contract-call? .mining-supply-chain confirm-receipt 
    u1 
    "5.6045" 
    "-0.1880")
```

### 5. Issue Ethical Certificate (Contract Owner Only)

```clarity
(contract-call? .mining-supply-chain issue-ethical-certificate u1)
```

## 📊 Data Queries

### Get Material Information
```clarity
(contract-call? .mining-supply-chain get-material u1)
```

### Verify Supply Chain
```clarity
(contract-call? .mining-supply-chain verify-supply-chain u1)
```

### Check Certificate Status
```clarity
(contract-call? .mining-supply-chain get-material-certificate u1)
```

### View Transfer History
```clarity
(contract-call? .mining-supply-chain get-material-history u1)
```

## 🔧 Development Setup

### Prerequisites
- Node.js 16+
- Clarinet CLI

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/BenjamJoseph/Mining-Supply-Chain-Traceability-System.git
cd Mining-Supply-Chain-Traceability-System
```

2. **Install dependencies**
```bash
npm install
```

3. **Check contract syntax**
```bash
clarinet check
```

4. **Run tests**
```bash
npm test
```

## 🏛️ Contract Structure

### Data Maps
- **participants** - Verified supply chain participants
- **materials** - Tracked materials with metadata
- **transfers** - Transfer transactions between participants
- **material-history** - Complete audit trail per material

### Key Functions
- `register-participant` - Add verified participants
- `register-material` - Create new tracked materials
- `transfer-material` - Move materials between stages
- `confirm-receipt` - Confirm material delivery
- `issue-ethical-certificate` - Certify ethical sourcing
- `verify-supply-chain` - Validate complete chain

## 📝 Valid Stage Transitions

The system enforces proper supply chain flow:

```
Mine → Transport → Refinery → Export
```

## 🔒 Security Features

- **Owner-only functions** for participant registration and certification
- **Role verification** ensures only authorized participants can perform actions
- **Stage validation** prevents invalid supply chain jumps
- **Status checks** ensure proper material state transitions

## 🌍 GPS & IoT Integration

- Real-time GPS coordinates for material tracking
- IoT sensor integration for environmental monitoring
- Immutable location history
- Verification hash support for data integrity

## 📈 Supply Chain Verification

The system provides complete traceability:
1. ✅ All materials must have valid ethical certificates
2. 📋 Complete transfer history is maintained
3. 🔍 GPS tracking validates physical movement
4. 🏆 Digital certificates prove ethical sourcing compliance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests with `npm test`
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🆘 Support

For questions or support, please open an issue on GitHub or contact the development team.

---

**Built with ❤️ using Stacks blockchain and Clarity smart contracts**

### Emergency Recall
- 🚨 **Emergency Recall** - Contract owner can recall materials to previous stages for quality or compliance issues

### 6. Emergency Recall (Contract Owner Only)

```clarity
(contract-call? .mining-supply-chain emergency-recall
    u1
    "refinery")
```

### Key Functions
- `emergency-recall` - Recall materials to previous stages for emergency situations

### Valid Recall Transitions

The system allows emergency recalls to previous stages:

```
Export ← Refinery ← Transport ← Mine
```

### Security Features

- **Emergency recall** restricted to contract owner for critical situations

### Supply Chain Verification

5. 🚨 Emergency recalls are tracked and can affect certification status
