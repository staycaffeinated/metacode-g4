package mmm.coffee.metacode.core.archetype;

/**
 * Holds the resolved package name and class name for a single archetype.
 * FreeMarker templates call these methods to get package/class information
 * without hardcoding the package structure.
 */
public class ArchetypeModel {

    private final String packageName;
    private final String className;

    public ArchetypeModel(String packageName, String className) {
        this.packageName = packageName;
        this.className = className;
    }

    public String packageName() {
        return packageName;
    }

    public String className() {
        return className;
    }

    public String fqcn() {
        return packageName + "." + className;
    }

    public String testClass() {
        return className + "Test";
    }

    public String integrationTestClass() {
        return className + "IntegrationTest";
    }

    public String varName() {
        if (className == null || className.isEmpty()) {
            return "obj";
        }
        return Character.toLowerCase(className.charAt(0)) + className.substring(1);
    }
}
